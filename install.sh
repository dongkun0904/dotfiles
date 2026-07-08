#!/bin/sh
# Run automatically by DevPod when DOTFILES_URL points at this repo
# (set via: bin/dpod options set DOTFILES_URL=https://github.com/dongkun0904/dotfiles).
# Safe to re-run manually inside a pod: cd ~/dotfiles && git pull && ./install.sh
set -eu

DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Claude Code status line -------------------------------------------------
# Copy the script and merge (not overwrite) the statusLine block into the
# user-global settings, preserving keys DevPod manages (e.g. auto mode).
mkdir -p "$HOME/.claude"
cp "$DIR/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
chmod +x "$HOME/.claude/statusline-command.sh"

f="$HOME/.claude/settings.json"
[ -s "$f" ] || echo '{}' > "$f"
if command -v jq >/dev/null 2>&1; then
  jq '.statusLine = {"type":"command","command":"sh ~/.claude/statusline-command.sh"}' \
    "$f" > "$f.tmp" && mv "$f.tmp" "$f"
else
  echo "WARN: jq not found; statusLine not added to settings.json" >&2
fi

# --- Shell aliases -----------------------------------------------------------
# Symlink so `git pull && ./install.sh` picks up changes. The ~/.dpod_aliases
# name and sourcing guard match the old dpod-start sync, so pods provisioned
# either way stay idempotent.
if [ -f "$DIR/zsh/aliases.zsh" ]; then
  ln -sf "$DIR/zsh/aliases.zsh" "$HOME/.dpod_aliases"
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || touch "$rc"
    grep -qsF '.dpod_aliases' "$rc" || \
      echo '[ -f ~/.dpod_aliases ] && . ~/.dpod_aliases' >> "$rc"
  done
fi

echo "dotfiles installed."
