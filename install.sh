#!/bin/bash
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------- Section 1: Append .bashrc ----------
MARKER="# >>> dotfiles .bashrc >>>"
if grep -qF "$MARKER" ~/.bashrc 2>/dev/null; then
  echo ".bashrc: dotfiles block already present, skipping"
else
  echo ".bashrc: appending dotfiles block"
  {
    echo ""
    echo "$MARKER"
    cat "$DOTFILES_DIR/.bashrc"
    echo "# <<< dotfiles .bashrc <<<"
  } >> ~/.bashrc
fi
source ~/.bashrc || true

# ---------- Section 2: Copy .gitconfig with codespace fixes ----------
echo ".gitconfig: copying and applying codespace fixes"
cp "$DOTFILES_DIR/.gitconfig" ~/.gitconfig
sed -i "s|/Users/donghyun/.gitignore_global|$HOME/.gitignore_global|g" ~/.gitconfig
sed -i 's|cursor --wait|code --wait|g' ~/.gitconfig
sed -i 's|!/opt/homebrew/bin/gh auth git-credential|!/.codespaces/bin/gitcredential_github.sh|g' ~/.gitconfig

# ---------- Section 3: Copy .gitignore_global ----------
echo ".gitignore_global: copying"
cp "$DOTFILES_DIR/.gitignore_global" ~/.gitignore_global

# ---------- Section 4: Copy bin/ scripts ----------
echo "bin: copying scripts to ~/.local/bin"
mkdir -p ~/.local/bin
cp "$DOTFILES_DIR/bin/"* ~/.local/bin/
chmod +x ~/.local/bin/*

# ---------- Section 5: Additive copy of .claude/ to betterup-monolith ----------
MONOLITH_DIR="$DOTFILES_DIR/../betterup-monolith"
if [ ! -d "$MONOLITH_DIR" ]; then
  echo ".claude: WARNING — betterup-monolith not found at $MONOLITH_DIR, skipping"
else
  echo ".claude: copying to betterup-monolith (additive, no-clobber)"
  TARGET="$MONOLITH_DIR/.claude"

  # Create directory structure
  mkdir -p "$TARGET/agents" "$TARGET/commands" "$TARGET/skills"

  # Copy top-level files (no-clobber)
  for f in "$DOTFILES_DIR/.claude/"*.json "$DOTFILES_DIR/.claude/"*.sh; do
    [ -f "$f" ] && cp -n "$f" "$TARGET/" 2>/dev/null || true
  done

  # Copy subdirectories: agents/*, commands/*, skills/*
  for category in agents commands skills; do
    for subdir in "$DOTFILES_DIR/.claude/$category"/*/; do
      [ -d "$subdir" ] || continue
      dirname="$(basename "$subdir")"
      mkdir -p "$TARGET/$category/$dirname"
      cp -rn "$subdir"* "$TARGET/$category/$dirname/" 2>/dev/null || true
    done
  done

  echo ".claude: done"
fi

echo "Dotfiles installed successfully!"
