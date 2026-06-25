#!/usr/bin/env bash
input=$(cat)

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
fast=$(echo "$input" | jq -r '.fast_mode // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')

parts=()

if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  ctx=$(printf "%.0f%%" "$used")
  if [ "$used_int" -ge 80 ]; then
    ctx=$'\033[31m'"${ctx}"$'\033[0m'
  fi
  parts+=("$ctx")
fi

[ -n "$effort" ] && parts+=("$effort")
[ "$fast" = "true" ] && parts+=("⚡")

if [ "${#parts[@]}" -gt 0 ]; then
  output="${parts[0]}"
  for part in "${parts[@]:1}"; do
    output="${output} | ${part}"
  done
  printf "%s" "$output"
fi
