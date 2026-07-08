# dotfiles

Personal dev-environment config, consumed automatically by BetterUp DevPods.

## How it's wired

```bash
bin/dpod options set DOTFILES_URL=https://github.com/dongkun0904/dotfiles
```

On every workspace creation, DevPod clones this repo to `$HOME/dotfiles` inside
the container and runs `install.sh`, which:

- installs the Claude Code status line (`claude/statusline-command.sh`) and
  merges the `statusLine` block into `~/.claude/settings.json` without
  clobbering pod-managed settings (e.g. the auto-mode default)
- symlinks `zsh/aliases.zsh` to `~/.dpod_aliases` and wires sourcing into
  `.bashrc` / `.zshrc`

## Updating an existing pod

New pods pick changes up automatically. For an already-created pod:

```bash
cd ~/dotfiles && git pull && ./install.sh
```

## What deliberately isn't here

No secrets, no `.zshenv`, no internal infrastructure aliases (kubectl/helm
contexts, aws sso) — this repo is public. Laptop-only config stays on the
laptop.
