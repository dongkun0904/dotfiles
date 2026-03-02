# Claude Code
alias cld="claude"
alias cldy="claude --dangerously-skip-permissions"
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

# Codespace
alias csdelete="gh codespace delete"

# AWS / Kubernetes
alias lhlogin="aws sso login && kubectl config use-context us-east-1-staging"
alias kp="kubectl --context=${US_STAGING_CONTEXT} "
alias aws_login="aws sso login --profile staging_us"
alias aws_staging_console='kp exec -it $(kubectl get pods | grep "^betterup-app-web-" | head -n 1 | awk "{print \$1}") -- bin/rails c'

# Work helpers
startwork () {
  if (( $# == 0 ))
  then
    echo "usage: startwork <issue-id-num> <branch-name>"
    echo "e.g. startwork 40209 add-send-notification-column"
  else
    echo "Starting working branch"
    git checkout main && git pull && git checkout -b BUAPP-$1/$2
  fi
}

# Prompt — region-aware
setopt prompt_subst
if [[ ! "$PROMPT" == *'${REGION_COLOR}${SHELL_PROFILE}'* ]]; then
  ORIGINAL_PROMPT=$PROMPT
  PROMPT='${REGION_COLOR}${SHELL_PROFILE} '
  PROMPT+="${ORIGINAL_PROMPT}"
fi

function betterup-arn:aws:eks:us() {
export REGION_COLOR=""
export SHELL_PROFILE="Betterup ARN:AWS:EKS:US"
  alias keast-1-staging='kubectl --context arn:aws:eks:us-east-1:315816552451:cluster/us-east-1-staging'
  alias keast-1-production='kubectl --context arn:aws:eks:us-east-1:954965609557:cluster/us-east-1-production'
}

function betterup-eu() {
export REGION_COLOR="%{%B%F{026}%}"
export SHELL_PROFILE="Betterup EU"
  alias kprod='kubectl --context eu-central-1-production'
  alias kstag='kubectl --context eu-central-1-staging'
}

function betterup-us() {
export REGION_COLOR="%{%B%F{197}%}"
export SHELL_PROFILE="Betterup US"
  alias kdev='kubectl --context us-east-1-dev'
  alias kpre='kubectl --context us-east-1-pre-production'
  alias kprod='kubectl --context us-east-1-production'
  alias kstag='kubectl --context us-east-1-staging'
}

# Docker CLI completions
fpath=(/Users/donghyun/.docker/completions $fpath)
autoload -Uz compinit
compinit
