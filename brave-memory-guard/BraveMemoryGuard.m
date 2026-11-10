#import <AppKit/AppKit.h>
#import <dispatch/dispatch.h>
#import <os/log.h>

static NSString *const BraveBundleID = @"com.brave.Browser";
static const int64_t WarningDelay = 10 * NSEC_PER_SEC;

typedef struct {
    unsigned long generation;
    bool warning;
    bool attempted;
} PressureEpisode;

typedef enum { NoAction, StartWarningTimer, RequestQuit } Action;

static Action handlePressure(PressureEpisode *episode, unsigned long pressure) {
    if (pressure & DISPATCH_MEMORYPRESSURE_CRITICAL) {
        if (episode->attempted) return NoAction;
        episode->warning = false;
        episode->attempted = true;
        return RequestQuit;
    }

    if (pressure & DISPATCH_MEMORYPRESSURE_WARN) {
        if (episode->warning || episode->attempted) return NoAction;
        episode->warning = true;
        episode->generation++;
        return StartWarningTimer;
    }

    if (pressure & DISPATCH_MEMORYPRESSURE_NORMAL) {
        episode->warning = false;
        episode->attempted = false;
        episode->generation++;
    }
    return NoAction;
}

static Action warningTimerFired(PressureEpisode *episode, unsigned long generation) {
    if (!episode->warning || episode->attempted || episode->generation != generation) {
        return NoAction;
    }
    episode->attempted = true;
    return RequestQuit;
}

static void requestBraveQuit(os_log_t logger, const char *reason) {
    NSArray<NSRunningApplication *> *apps =
        [NSRunningApplication runningApplicationsWithBundleIdentifier:BraveBundleID];
    for (NSRunningApplication *app in apps) {
        BOOL sent = [app terminate];
        os_log(logger, "Normal quit request for Brave (pid %{public}d): %{public}s; reason: %{public}s",
               app.processIdentifier, sent ? "sent" : "failed", reason);
    }
    if (apps.count == 0) {
        os_log(logger, "Brave was not running; reason: %{public}s", reason);
    }
}

static int selfTest(void) {
    PressureEpisode episode = {0};
    assert(handlePressure(&episode, DISPATCH_MEMORYPRESSURE_WARN) == StartWarningTimer);
    unsigned long firstWarning = episode.generation;
    assert(handlePressure(&episode, DISPATCH_MEMORYPRESSURE_WARN) == NoAction);
    assert(handlePressure(&episode, DISPATCH_MEMORYPRESSURE_NORMAL) == NoAction);
    assert(handlePressure(&episode, DISPATCH_MEMORYPRESSURE_WARN) == StartWarningTimer);
    assert(warningTimerFired(&episode, firstWarning) == NoAction);
    assert(warningTimerFired(&episode, episode.generation) == RequestQuit);
    assert(handlePressure(&episode, DISPATCH_MEMORYPRESSURE_CRITICAL) == NoAction);
    assert(handlePressure(&episode, DISPATCH_MEMORYPRESSURE_NORMAL) == NoAction);
    assert(handlePressure(&episode, DISPATCH_MEMORYPRESSURE_WARN) == StartWarningTimer);
    assert(handlePressure(&episode, DISPATCH_MEMORYPRESSURE_CRITICAL) == RequestQuit);
    assert(warningTimerFired(&episode, episode.generation) == NoAction);
    assert(handlePressure(&episode, DISPATCH_MEMORYPRESSURE_NORMAL) == NoAction);
    assert(handlePressure(&episode, DISPATCH_MEMORYPRESSURE_CRITICAL) == RequestQuit);
    puts("Passed: warning timer, recovery, critical escalation, and one attempt per episode.");
    return 0;
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc == 2 && strcmp(argv[1], "--self-test") == 0) return selfTest();
        if (argc != 1) return 2;

        os_log_t logger = os_log_create("local.brave-memory-guard", "pressure");
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_MEMORYPRESSURE, 0,
            DISPATCH_MEMORYPRESSURE_NORMAL | DISPATCH_MEMORYPRESSURE_WARN |
            DISPATCH_MEMORYPRESSURE_CRITICAL, queue);
        if (source == nil) {
            os_log_error(logger, "Could not create memory-pressure event source");
            return 1;
        }

        __block PressureEpisode episode = {0};
        dispatch_source_set_event_handler(source, ^{
            Action action = handlePressure(&episode, dispatch_source_get_data(source));
            if (action == RequestQuit) {
                requestBraveQuit(logger, "critical memory pressure");
            } else if (action == StartWarningTimer) {
                unsigned long generation = episode.generation;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, WarningDelay), queue, ^{
                    if (warningTimerFired(&episode, generation) == RequestQuit) {
                        requestBraveQuit(logger, "10 seconds of warning-level memory pressure");
                    }
                });
            }
        });

        dispatch_activate(source);
        os_log(logger, "Listening for memory pressure; quit target is Brave Browser");
        dispatch_main();
    }
}
