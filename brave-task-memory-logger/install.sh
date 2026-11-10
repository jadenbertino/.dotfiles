#!/bin/bash
set -euo pipefail

source_dir="$(cd "$(dirname "$0")" && pwd)"
label="local.brave-task-memory-logger"
domain="gui/$(id -u)"
support_dir="$HOME/Library/Application Support/BraveTaskMemoryLogger"
app="$support_dir/Brave Task Memory Logger.app"
binary="$app/Contents/MacOS/brave-task-memory-logger"
log_file="$support_dir/samples.jsonl"
agent_dir="$HOME/Library/LaunchAgents"
agent="$agent_dir/$label.plist"

if [[ "${1:-}" == --verify ]]; then
    if ! status="$(launchctl print "$domain/$label" 2>/dev/null)" || [[ "$status" != *'state = running'* ]]; then
        printf 'The logger is not running. Run install.sh first.\n' >&2
        exit 1
    fi
    for ((attempt = 0; attempt <= 20; attempt++)); do
        if [[ -s "$log_file" ]] && (( $(date +%s) - $(stat -f %m "$log_file") <= 40 )); then
            printf 'Verified: the login agent wrote a recent memory sample to %s\n' "$log_file"
            exit 0
        fi
        if (( attempt == 0 )); then
            printf 'Logger is running. Waiting up to 40 seconds for a memory sample…\n'
        fi
        if (( attempt == 20 )); then break; fi
        sleep 2
    done
    printf 'No recent sample. Enable Brave Task Memory Logger in Accessibility and leave Brave’s Task Manager open on All tasks.\n' >&2
    printf 'For the logger’s status messages, run:\n  /usr/bin/log show --last 5m --predicate '\''subsystem == "%s"'\''\n' "$label" >&2
    exit 1
fi

build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
staged_app="$build_dir/Brave Task Memory Logger.app"
mkdir -p "$staged_app/Contents/MacOS"
/usr/bin/clang -fobjc-arc -O2 -Wall -Wextra -Werror -Wno-unused-parameter \
    -framework AppKit -framework ApplicationServices \
    "$source_dir/BraveTaskMemoryLogger.m" -o "$staged_app/Contents/MacOS/brave-task-memory-logger"
"$staged_app/Contents/MacOS/brave-task-memory-logger" --self-test

cat > "$staged_app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
    <key>CFBundleIdentifier</key><string>local.brave-task-memory-logger</string>
    <key>CFBundleExecutable</key><string>brave-task-memory-logger</string>
    <key>CFBundleName</key><string>Brave Task Memory Logger</string>
    <key>CFBundleDisplayName</key><string>Brave Task Memory Logger</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSUIElement</key><true/>
</dict></plist>
PLIST
/usr/bin/codesign --force --sign - "$staged_app"

staged_agent="$build_dir/$label.plist"
/usr/bin/plutil -create xml1 "$staged_agent"
/usr/bin/plutil -insert Label -string "$label" "$staged_agent"
/usr/bin/plutil -insert ProgramArguments -array "$staged_agent"
/usr/libexec/PlistBuddy -c "Add :ProgramArguments:0 string $binary" \
    -c "Add :ProgramArguments:1 string $log_file" "$staged_agent"
/usr/bin/plutil -insert RunAtLoad -bool YES "$staged_agent"
/usr/bin/plutil -insert KeepAlive -bool YES "$staged_agent"
/usr/bin/plutil -lint "$staged_agent"

mkdir -p "$support_dir" "$agent_dir"
if launchctl print "$domain/$label" >/dev/null 2>&1; then
    launchctl bootout "$domain/$label"
fi
/usr/bin/ditto "$staged_app" "$app"
/usr/bin/install -m 644 "$staged_agent" "$agent"
launchctl enable "$domain/$label"
launchctl bootstrap "$domain" "$agent"

printf 'Brave Task Memory Logger is registered to start at login.\n'
printf 'In System Settings → Privacy & Security → Accessibility, add and enable:\n  %s\n' "$app"
printf 'Open Brave’s Window → Task Manager, select All tasks, and leave it open.\n'
printf 'Then run:\n  /bin/bash "%s/install.sh" --verify\n' "$source_dir"
