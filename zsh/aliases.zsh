# Shell aliases synced into DevPod workspaces via install.sh.
# Laptop-only / internal-infra aliases (kubectl, helm, aws sso) intentionally excluded.

# Claude Code
alias cld="claude"
alias cldy="claude --dangerously-skip-permissions"
alias cldyf="claude --dangerously-skip-permissions --model fable"
alias cldyo="claude --dangerously-skip-permissions --model opus"
alias cldys="claude --dangerously-skip-permissions --model sonnet"
alias cldyh="claude --dangerously-skip-permissions --model haiku"
alias cldapi="unset CLAUDE_CODE_OAUTH_TOKEN && claude"
alias cldyapi="unset CLAUDE_CODE_OAUTH_TOKEN && claude --dangerously-skip-permissions"
alias cldsub="unset ANTHROPIC_API_KEY && claude"
alias cldysub="unset ANTHROPIC_API_KEY && claude --dangerously-skip-permissions"

# Git
alias gs="git status"
alias gb="git branch"
alias glb="git checkout -"
alias gcm="git checkout main && git pull"
alias grm="git checkout main && git pull && git checkout - && git rebase main"
alias grmi="git rebase main -i"
alias gnb="git checkout -b $1"
alias gc="git commit -m $1"
alias gcfix="git commit --fixup $1"
alias gca="git add . && git commit -m $1"
alias gcafix="git add . && git commit --fixup $1"
alias gcamend="git commit --amend"
alias greset="git reset HEAD --hard"
alias gpfwl="git push origin --force-with-lease"
