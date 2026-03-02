#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link_dotfiles() {
  # Zsh config split:
  #   ~/.zshenv    — env vars & secrets (NOT tracked — contains tokens)
  #   ~/.zprofile  — tool initializers (OrbStack, rbenv, conda, NVM)
  #   ~/.zshrc     — interactive shell (aliases, functions, prompt, completions)
  ln -sf "$DOTFILES_DIR/.zprofile" ~/.zprofile
  ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc
  ln -sf "$DOTFILES_DIR/.gitconfig" ~/.gitconfig
  ln -sf "$DOTFILES_DIR/.gitignore_global" ~/.gitignore_global

  # Link Claude Code user-level config
  mkdir -p ~/.claude
  ln -sf "$DOTFILES_DIR/.claude/settings.json" ~/.claude/settings.json
  ln -sf "$DOTFILES_DIR/.claude/statusline-command.sh" ~/.claude/statusline-command.sh

  # Link custom scripts to ~/.local/bin
  mkdir -p ~/.local/bin
  for script in "$DOTFILES_DIR"/bin/*; do
    [ -f "$script" ] && ln -sf "$script" ~/.local/bin/
  done

  # Install CLI tools
  command -v claude >/dev/null || npm install -g @anthropic-ai/claude-code
  npm install -g tldr

  # Set up Git shortcuts
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.st status

  echo "Dotfiles installed successfully!"
}

link_claude_project() {
  local project_path="$1"
  if [ -z "$project_path" ]; then
    echo "Usage: $0 link-claude <project-path>"
    exit 1
  fi

  # Resolve to absolute path
  project_path="$(cd "$project_path" 2>/dev/null && pwd)"
  local claude_dir="$project_path/.claude"

  if [ ! -d "$claude_dir" ]; then
    echo "Error: $claude_dir does not exist"
    exit 1
  fi

  # Link personal Claude extensions into the project
  ln -sf "$DOTFILES_DIR/.claude/settings.local.json" "$claude_dir/settings.local.json"

  mkdir -p "$claude_dir/agents"
  ln -sfn "$DOTFILES_DIR/.claude/agents/humanlayer" "$claude_dir/agents/humanlayer"

  mkdir -p "$claude_dir/commands"
  ln -sfn "$DOTFILES_DIR/.claude/commands/humanlayer" "$claude_dir/commands/humanlayer"

  mkdir -p "$claude_dir/skills"
  ln -sfn "$DOTFILES_DIR/.claude/skills/jira-acli" "$claude_dir/skills/jira-acli"

  echo "Claude Code project config linked to $project_path"
}

case "${1:-}" in
  link-claude)
    link_claude_project "$2"
    ;;
  *)
    link_dotfiles
    ;;
esac
