# dotfiles

Personal development environment configuration for macOS and GitHub Codespaces.

## What's Included

| File / Directory | Purpose |
|---|---|
| `.bashrc` | Shell aliases for Git, Claude Code CLI, Kubernetes, AWS |
| `.gitconfig` | Git settings, credential helpers, editor config |
| `.gitignore_global` | Global ignore patterns (IDE files, AI docs, worktrees) |
| `bin/` | Utility scripts installed to `~/.local/bin` |
| `.claude/` | Claude Code extensions — commands, agents, skills, settings |
| `install.sh` | Setup script that deploys everything |

## Installation

```bash
git clone <repo-url> ~/Desktop/repo/dotfiles
cd ~/Desktop/repo/dotfiles
./install.sh
```

The install script:

1. **Appends `.bashrc`** — adds aliases to `~/.bashrc` between markers (idempotent)
2. **Copies `.gitconfig`** — installs to `~/.gitconfig`, adjusting paths for Codespaces if needed
3. **Copies `.gitignore_global`** — installs to `~/.gitignore_global`
4. **Copies `bin/` scripts** — installs to `~/.local/bin` (creates directory if needed)
5. **Copies `.claude/` extensions** — if `../betterup-monolith` exists, copies commands/agents/skills there (additive, no-clobber)

### Codespace Support

When running inside a GitHub Codespace, `install.sh` automatically:

- Swaps the editor from `cursor --wait` to `code --wait`
- Replaces the Git credential helper with the Codespace-compatible version

## Shell Aliases

### Claude Code

| Alias | Description |
|---|---|
| `cld` | `claude` |
| `cldy` | `claude --yes` (auto-approve) |
| `cldyo` | `claude --yes --model opus` |
| `cldys` | `claude --yes --model sonnet` |
| `cldyh` | `claude --yes --model haiku` |
| `cldapi` | `claude --yes --model opus --allowedTools mcp__context7__*` |

### Git

| Alias | Description |
|---|---|
| `gs` | `git status` |
| `gb` | `git branch` |
| `gcm` | `git checkout main` |
| `grm` | `git rebase main` |
| `gc` | `git commit` |
| `gca` | `git commit --all` |
| `gp` | `git push` |
| `gl` | `git log --oneline -20` |

## Scripts

Installed to `~/.local/bin/`:

| Script | Description |
|---|---|
| `create-codespace` | Creates a GitHub Codespace for betterup-monolith on a given branch, sets up dotfiles, and connects via SSH |

## Claude Code Extensions

### Commands (27)

Slash commands for Claude Code, organized by workflow:

- **Planning** — `/create_plan`, `/iterate_plan`, `/validate_plan`
- **Research** — `/research_codebase`, `/research_codebase_generic`
- **Implementation** — `/implement_plan`, `/oneshot`, `/oneshot_plan`
- **Git/PR** — `/commit`, `/describe_pr`, `/ci_commit`, `/ci_describe_pr`
- **Handoffs** — `/create_handoff`, `/resume_handoff`
- **Debugging** — `/debug`
- **Project Management** — `/linear`

### Agents (6)

Specialized research agents:

| Agent | Role |
|---|---|
| `codebase-locator` | Finds where files and components live |
| `codebase-analyzer` | Explains how code works |
| `codebase-pattern-finder` | Finds existing pattern examples |
| `thoughts-locator` | Discovers relevant docs in `thoughts/` |
| `thoughts-analyzer` | Extracts insights from documents |
| `web-search-researcher` | Searches external documentation |

### Skills

- **jira-acli** — Interact with Jira and Confluence from Claude Code (view, create, edit, transition, search issues; read Confluence pages)

## Configuration

### Claude Code Settings (`.claude/settings.json`)

- Model: Opus with 1M context and always-thinking
- Custom status line showing git branch, model, and context usage
- BetterUp engineering marketplace integration

### Status Line

The custom status line (`.claude/statusline-command.sh`) displays:

```
user@host | ~/repo/project | main | opus | 42%
```
