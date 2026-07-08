#!/bin/sh
# Claude Code status line
# Order: dir | git branch | context bar | cost | rate-limit usage | PR status | model | thinking/effort
# Managed by the statusline-setup agent - ask Claude to update via that agent.

input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
dirname=$(basename "$dir")
model=$(echo "$input" | jq -r '.model.display_name')

branch=$(cd "$dir" 2>/dev/null && git --no-optional-locks branch --show-current 2>/dev/null)

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

effort=$(echo "$input" | jq -r '.effort.level // empty')
thinking=$(echo "$input" | jq -r '.thinking.enabled // false')

prnum=$(echo "$input" | jq -r '.pr.number // empty')
prstate=$(echo "$input" | jq -r '.pr.review_state // empty')

# Context usage as a 10-slot bar, colored green/yellow/red by fullness
ctxseg=""
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  filled=$((used_int / 10))
  [ "$filled" -gt 10 ] && filled=10
  bar=""
  i=0
  while [ "$i" -lt 10 ]; do
    if [ "$i" -lt "$filled" ]; then bar="${bar}█"; else bar="${bar}░"; fi
    i=$((i + 1))
  done
  if [ "$used_int" -ge 85 ]; then c='\033[91m'
  elif [ "$used_int" -ge 60 ]; then c='\033[93m'
  else c='\033[92m'; fi
  ctxseg=$(printf '%b' "${c}${bar}\033[0;96m ${used_int}%")
fi

segments="$dirname"
[ -n "$branch" ] && segments="$segments|$branch"
[ -n "$ctxseg" ] && segments="$segments|$ctxseg"
[ -n "$cost" ] && segments="$segments|\$$(printf '%.2f' "$cost")"

rl=""
[ -n "$five" ] && rl="5h:${five}%"
if [ -n "$week" ]; then
  if [ -n "$rl" ]; then rl="$rl 7d:${week}%"; else rl="7d:${week}%"; fi
fi
[ -n "$rl" ] && segments="$segments|$rl"

[ -n "$prnum" ] && segments="$segments|PR#${prnum}${prstate:+ (${prstate})}"

segments="$segments|$model"

te=""
if [ "$thinking" = "true" ]; then te="thinking"; fi
if [ -n "$effort" ]; then
  if [ -n "$te" ]; then te="$te, eff:${effort}"; else te="eff:${effort}"; fi
fi
[ -n "$te" ] && segments="$segments|$te"

# Print bright cyan, pipe-separated segments
out=$(printf '%s' "$segments" | sed 's/|/ \xc2\xb7 /g')
printf '\033[96m%s\033[0m' "$out"
