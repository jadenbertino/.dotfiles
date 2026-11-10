#!/bin/bash
set -euo pipefail

source_dir="$(cd "$(dirname "$0")" && pwd)"
support_dir="$HOME/Library/Application Support/BraveMemoryGuard"
agent_dir="$HOME/Library/LaunchAgents"
label="local.brave-memory-guard"
domain="gui/$(id -u)"
plist="$agent_dir/$label.plist"

"$source_dir/brave-memory-guard" --self-test
mkdir -p "$support_dir" "$agent_dir"
tmp_plist="$(mktemp "$agent_dir/.brave-memory-guard.XXXXXX")"
trap 'rm -f "$tmp_plist"' EXIT
/usr/bin/install -m 755 "$source_dir/brave-memory-guard" "$support_dir/brave-memory-guard"
/usr/bin/install -m 644 "$source_dir/$label.plist" "$tmp_plist"
/usr/libexec/PlistBuddy -c 'Delete :ProgramArguments:0' \
    -c "Add :ProgramArguments:0 string $support_dir/brave-memory-guard" "$tmp_plist"
/usr/bin/plutil -lint "$tmp_plist"
mv -f "$tmp_plist" "$plist"

if launchctl print "$domain/$label" >/dev/null 2>&1; then
    launchctl bootout "$domain/$label"
fi
launchctl enable "$domain/$label"
launchctl bootstrap "$domain" "$plist"
for attempt in 1 2 3 4 5; do
    status="$(launchctl print "$domain/$label")"
    if printf '%s\n' "$status" | grep -q 'state = running'; then
        printf 'Brave Memory Guard is running and will start at login.\n'
        exit 0
    fi
    sleep 1
done
printf '%s\n' "$status" >&2
exit 1
