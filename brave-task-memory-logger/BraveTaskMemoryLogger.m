#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
#import <fcntl.h>
#import <os/log.h>
#import <sys/stat.h>
#import <unistd.h>

static NSString *const BraveID = @"com.brave.Browser";
static const off_t LogLimit = 2 * 1024 * 1024;
static const NSTimeInterval SampleInterval = 30;

static id attribute(AXUIElementRef element, CFStringRef name) {
    CFTypeRef value = NULL;
    if (AXUIElementCopyAttributeValue(element, name, &value) != kAXErrorSuccess) return nil;
    return CFBridgingRelease(value);
}

static NSString *cellText(AXUIElementRef cell) {
    for (NSString *key in @[@"AXTitle", @"AXValue", @"AXDescription"]) {
        id value = attribute(cell, (__bridge CFStringRef)key);
        if ([value isKindOfClass:NSString.class] && [value length]) return value;
    }
    return @"";
}

static NSArray *childrenWithRole(AXUIElementRef element, NSString *role, CFStringRef key) {
    NSMutableArray *matching = [NSMutableArray array];
    for (id child in attribute(element, key)) {
        if ([attribute((__bridge AXUIElementRef)child, kAXRoleAttribute) isEqual:role]) {
            [matching addObject:child];
        }
    }
    return matching;
}

static id findTable(AXUIElementRef element, NSUInteger depth) {
    if ([attribute(element, kAXRoleAttribute) isEqual:@"AXTable"]) return (__bridge id)element;
    if (!depth) return nil;
    for (id child in attribute(element, kAXChildrenAttribute)) {
        id table = findTable((__bridge AXUIElementRef)child, depth - 1);
        if (table) return table;
    }
    return nil;
}

static NSNumber *memoryBytes(NSString *text) {
    NSScanner *scanner = [NSScanner scannerWithString:[text stringByReplacingOccurrencesOfString:@"," withString:@""]];
    scanner.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    double value = 0;
    if (![scanner scanDouble:&value] || !isfinite(value) || value < 0) return nil;
    NSString *unit = [[scanner.string substringFromIndex:scanner.scanLocation]
        stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].uppercaseString;
    NSDictionary *units = @{@"B": @1, @"KB": @1024, @"MB": @(1024 * 1024), @"GB": @(1024LL * 1024 * 1024)};
    NSNumber *multiplier = units[unit];
    return multiplier ? @(llround(value * multiplier.doubleValue)) : nil;
}

static NSArray *topProcesses(NSArray<NSArray<NSString *> *> *rows, NSString **problem) {
    NSUInteger task = NSNotFound, memory = NSNotFound, pid = NSNotFound;
    NSMutableDictionary<NSNumber *, NSMutableDictionary *> *processes = [NSMutableDictionary dictionary];
    for (NSArray<NSString *> *cells in rows) {
        NSUInteger header = [cells indexOfObject:@"Column Task"];
        if (header != NSNotFound) {
            task = header;
            memory = [cells indexOfObjectPassingTest:^BOOL(NSString *cell, NSUInteger index, BOOL *stop) {
                return [cell hasPrefix:@"Column Memory Footprint"];
            }];
            pid = [cells indexOfObjectPassingTest:^BOOL(NSString *cell, NSUInteger index, BOOL *stop) {
                return [cell hasPrefix:@"Column Process ID"];
            }];
            continue;
        }
        if (task >= cells.count || memory >= cells.count || pid >= cells.count) continue;
        NSString *pidText = [cells[pid] stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSScanner *scanner = [NSScanner scannerWithString:pidText];
        long long processID = 0;
        if (![scanner scanLongLong:&processID] || !scanner.isAtEnd || processID <= 0 || !cells[task].length) continue;

        NSMutableDictionary *process = processes[@(processID)];
        if (!process) {
            process = [@{@"pid": @(processID), @"tasks": [NSMutableArray array]} mutableCopy];
            processes[@(processID)] = process;
        }
        NSMutableArray *tasks = process[@"tasks"];
        if (![tasks containsObject:cells[task]]) [tasks addObject:cells[task]];
        NSNumber *bytes = memoryBytes(cells[memory]);
        if (bytes && (!process[@"bytes"] || [bytes compare:process[@"bytes"]] == NSOrderedDescending)) {
            process[@"bytes"] = bytes;
        }
    }

    if (task == NSNotFound || memory == NSNotFound || pid == NSNotFound) {
        *problem = @"Task Manager needs the Task, Memory Footprint, and Process ID columns.";
        return nil;
    }

    NSMutableArray *measured = [NSMutableArray array];
    for (NSDictionary *process in processes.allValues) {
        if (process[@"bytes"]) [measured addObject:process];
    }
    if (!measured.count) {
        *problem = @"Task Manager has no measured rows yet. Select All tasks, clear the search, and wait a few seconds.";
        return nil;
    }
    [measured sortUsingComparator:^NSComparisonResult(NSDictionary *left, NSDictionary *right) {
        NSComparisonResult order = [right[@"bytes"] compare:left[@"bytes"]];
        return order == NSOrderedSame ? [left[@"pid"] compare:right[@"pid"]] : order;
    }];
    return [measured subarrayWithRange:NSMakeRange(0, MIN(measured.count, 15))];
}

static NSArray *readProcesses(NSString **problem) {
    if (!AXIsProcessTrusted()) {
        *problem = @"Accessibility access is required for Brave Task Memory Logger.";
        return nil;
    }
    NSRunningApplication *brave = [NSRunningApplication runningApplicationsWithBundleIdentifier:BraveID].firstObject;
    if (!brave) {
        *problem = @"Brave is closed.";
        return nil;
    }
    id app = CFBridgingRelease(AXUIElementCreateApplication(brave.processIdentifier));
    AXUIElementRef application = (__bridge AXUIElementRef)app;
    AXUIElementSetMessagingTimeout(application, 2.0f);
    for (id window in attribute(application, kAXWindowsAttribute)) {
        AXUIElementRef element = (__bridge AXUIElementRef)window;
        if (![attribute(element, kAXTitleAttribute) isEqual:@"Task Manager"]) continue;
        id tableObject = findTable(element, 8);
        if (!tableObject) break;
        AXUIElementRef table = (__bridge AXUIElementRef)tableObject;
        NSArray *rows = childrenWithRole(table, @"AXRow", kAXChildrenAttribute);
        if (!rows.count) rows = childrenWithRole(table, @"AXRow", kAXRowsAttribute);

        NSMutableArray *cellRows = [NSMutableArray array];
        id header = attribute(table, CFSTR("AXHeader"));
        if (header && CFGetTypeID((__bridge CFTypeRef)header) == AXUIElementGetTypeID() && ![rows containsObject:header]) {
            rows = [@[header] arrayByAddingObjectsFromArray:rows];
        }
        for (id row in rows) {
            NSMutableArray *cells = [NSMutableArray array];
            for (id cell in childrenWithRole((__bridge AXUIElementRef)row, @"AXCell", kAXChildrenAttribute)) {
                [cells addObject:cellText((__bridge AXUIElementRef)cell)];
            }
            [cellRows addObject:cells];
        }
        return topProcesses(cellRows, problem);
    }
    *problem = @"Open Brave’s Window → Task Manager and leave the window open.";
    return nil;
}

static BOOL writeLine(NSData *data, NSString *path) {
    const char *file = path.fileSystemRepresentation;
    struct stat info;
    if (stat(file, &info) == 0 && info.st_size + (off_t)data.length + 1 > LogLimit) {
        NSString *previous = [path stringByAppendingString:@".previous"];
        if (rename(file, previous.fileSystemRepresentation) != 0) return NO;
    }
    int fd = open(file, O_WRONLY | O_APPEND | O_CREAT | O_NOFOLLOW, 0600);
    if (fd < 0) return NO;
    NSMutableData *line = [data mutableCopy];
    [line appendBytes:"\n" length:1];
    ssize_t count = write(fd, line.bytes, line.length);
    close(fd);
    return count == (ssize_t)line.length;
}

static NSData *encodeSample(NSArray *processes) {
    NSISO8601DateFormatter *formatter = [NSISO8601DateFormatter new];
    NSDictionary *sample = @{@"timestamp": [formatter stringFromDate:NSDate.date], @"processes": processes};
    return [NSJSONSerialization dataWithJSONObject:sample options:NSJSONWritingSortedKeys error:NULL];
}

static int selfTest(void) {
    NSString *problem = nil;
    NSArray *rows = @[@[@"Column Task", @"Column Memory Footprint sorted in descending order", @"Column Process ID"],
        @[@"Tab: Example", @"537 MB", @"90434"], @[@"Subframe: Example", @"–", @"90434"],
        @[@"Extension: Example", @"1.2 GB", @"22735"], @[@"GPU Process", @"1,024 KB", @"95310"]];
    NSArray *processes = topProcesses(rows, &problem);
    if (processes.count != 3 || ![processes[0][@"pid"] isEqual:@22735] ||
        [processes[1][@"tasks"] count] != 2 || ![processes[2][@"bytes"] isEqual:@1048576]) return 1;
    char temp[] = "/tmp/brave-task-memory.XXXXXX";
    int fd = mkstemp(temp);
    if (fd < 0) return 1;
    close(fd);
    NSString *path = @(temp);
    NSData *sample = encodeSample(processes);
    BOOL success = writeLine(sample, path);
    NSData *written = [NSData dataWithContentsOfFile:path];
    unlink(temp);
    NSDictionary *decoded = written ? [NSJSONSerialization JSONObjectWithData:written options:0 error:NULL] : nil;
    if (!success || [decoded[@"processes"] count] != 3) return 1;
    puts("Passed: memory units, process ranking, shared-PID grouping, and JSONL write/read.");
    return 0;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc == 2 && strcmp(argv[1], "--self-test") == 0) return selfTest();
        BOOL once = argc == 2 && strcmp(argv[1], "--once") == 0;
        if (argc != 2) return 2;
        NSString *logPath = @(argv[1]);
        NSString *lastProblem = nil;
        os_log_t logger = os_log_create("local.brave-task-memory-logger", "sampler");
        do {
            @autoreleasepool {
                NSString *problem = nil;
                NSArray *processes = readProcesses(&problem);
                NSData *sample = processes ? encodeSample(processes) : nil;
                if (sample && once) {
                    fwrite(sample.bytes, 1, sample.length, stdout);
                    puts("");
                    return 0;
                }
                if (once) {
                    fprintf(stderr, "%s\n", (problem ?: @"Could not encode sample.").UTF8String);
                    return 1;
                }
                if (processes && (!sample || !writeLine(sample, logPath))) problem = @"Could not write a memory sample.";
                if (problem && ![problem isEqual:lastProblem]) os_log(logger, "%{public}@", problem);
                lastProblem = problem;
            }
            [NSThread sleepForTimeInterval:SampleInterval];
        } while (YES);
    }
}
