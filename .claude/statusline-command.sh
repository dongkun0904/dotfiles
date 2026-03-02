#!/usr/bin/env bash
# Claude Code status line script

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten the cwd: replace $HOME with ~
home="$HOME"
short_cwd="${cwd/#$home/~}"

# Git branch (skip locks for safety)
git_branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi

# Build the status parts
parts=""

# user@host cwd
parts="$(whoami)@$(hostname -s) $short_cwd"

# git branch
if [ -n "$git_branch" ]; then
  parts="$parts [$git_branch]"
fi

# model
if [ -n "$model" ]; then
  parts="$parts | $model"
fi

# context usage
if [ -n "$used" ]; then
  printf_used=$(printf "%.0f" "$used" 2>/dev/null || echo "$used")
  parts="$parts | ctx: ${printf_used}%"
fi

printf "%s\n" "$parts"
