#!/usr/bin/env bash
input=$(cat)
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used" ]; then
  cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
  label=$(printf "ctx %.0f%%" "$used")

  used_int=$(printf "%.0f" "$used")
  if [ "$used_int" -ge 80 ]; then
    label=$'\033[31m'"${label}"$'\033[0m'
  fi

  printf "%*s" "$cols" "$label"
fi
