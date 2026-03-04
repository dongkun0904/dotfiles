#!/bin/bash

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link_dotfiles() {
  # Clean up old zsh symlinks
  rm -f ~/.zprofile ~/.zshrc

  # Shell config (bash for codespace compatibility)
  ln -sf "$DOTFILES_DIR/.bashrc" ~/.bashrc
  ln -sf "$DOTFILES_DIR/.gitconfig" ~/.gitconfig
  ln -sf "$DOTFILES_DIR/.gitignore_global" ~/.gitignore_global

  # Link Claude Code user-level config
  mkdir -p ~/.claude
  ln -sf "$DOTFILES_DIR/.claude/settings.json" ~/.claude/settings.json
  ln -sf "$DOTFILES_DIR/.claude/statusline-command.sh" ~/.claude/statusline-command.sh

  # Copy Claude commands, agents, and skills to user-level
  # (Claude Code doesn't follow symlinks for command discovery)
  mkdir -p ~/.claude/commands ~/.claude/agents ~/.claude/skills
  for item in "$DOTFILES_DIR"/.claude/commands/*/; do
    [ -d "$item" ] && cp -r "${item%/}" ~/.claude/commands/
  done
  for item in "$DOTFILES_DIR"/.claude/agents/*/; do
    [ -d "$item" ] && cp -r "${item%/}" ~/.claude/agents/
  done
  for item in "$DOTFILES_DIR"/.claude/skills/*/; do
    [ -d "$item" ] && cp -r "${item%/}" ~/.claude/skills/
  done

  # Link custom scripts to ~/.local/bin
  mkdir -p ~/.local/bin
  for script in "$DOTFILES_DIR"/bin/*; do
    [ -f "$script" ] && ln -sf "$script" ~/.local/bin/
  done

  # Install CLI tools
  command -v claude >/dev/null || npm install -g @anthropic-ai/claude-code
  npm install -g tldr

  # Fix platform-specific paths in codespace environments
  if [ "${CODESPACES:-}" = "true" ]; then
    git config --global core.excludesfile ~/.gitignore_global
    git config --global core.editor "code --wait"
    git config --global credential.https://github.com.helper ""
    git config --global credential.https://github.com.helper "!/.codespaces/bin/gitcredential_github.sh"
    git config --global credential.https://gist.github.com.helper ""
    git config --global credential.https://gist.github.com.helper "!/.codespaces/bin/gitcredential_github.sh"
  fi

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

link_ai_workbench() {
  local awb_dir="${1:-$HOME/ai-workbench}"
  local src="$awb_dir/dh_lee/.claude"

  if [ ! -d "$src" ]; then
    echo "Error: $src does not exist"
    exit 1
  fi

  mkdir -p ~/.claude/commands ~/.claude/skills ~/.claude/agents

  # Copy all command directories and top-level command files
  # (Claude Code doesn't follow symlinks for command discovery)
  for item in "$src"/commands/*/; do
    [ -d "$item" ] && cp -r "${item%/}" ~/.claude/commands/
  done
  for item in "$src"/commands/*.md; do
    [ -f "$item" ] && cp "$item" ~/.claude/commands/
  done

  # Copy all skills
  for item in "$src"/skills/*/; do
    [ -d "$item" ] && cp -r "${item%/}" ~/.claude/skills/
  done

  # Copy all agents
  for item in "$src"/agents/*.md; do
    [ -f "$item" ] && cp "$item" ~/.claude/agents/
  done
  for item in "$src"/agents/*/; do
    [ -d "$item" ] && cp -r "${item%/}" ~/.claude/agents/
  done

  # Copy hooks and templates
  [ -d "$src/hooks" ] && cp -r "$src/hooks" ~/.claude/
  [ -d "$src/templates" ] && cp -r "$src/templates" ~/.claude/

  # Copy helper scripts
  for item in "$src"/ensure-draft-pr.js "$src"/ensure-draft-pr.test.js; do
    [ -f "$item" ] && cp "$item" ~/.claude/
  done

  echo "AI workbench Claude commands linked from $src"
}

case "${1:-}" in
  link-claude)
    link_claude_project "$2"
    ;;
  link-ai-workbench)
    link_ai_workbench "${2:-}"
    ;;
  *)
    link_dotfiles
    ;;
esac
