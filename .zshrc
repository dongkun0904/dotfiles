# aliases
alias cld="claude"
alias cldy="claude --dangerously-skip-permissions"
alias cldyo="claude --dangerously-skip-permissions --model opus"
alias cldys="claude --dangerously-skip-permissions --model sonnet"
alias cldyh="claude --dangerously-skip-permissions --model haiku"
alias lhlogin="aws sso login && kubectl config use-context us-east-1-staging"
alias glb="git checkout -" # last branch
alias gcm="git checkout main && git pull" # checkout main
alias grm="git checkout main && git pull && git checkout - && git rebase main" # rebase to latest main
alias grmi="git rebase main -i" # rebase interactive

alias gnb="git checkout -b $1" # git new branch: gnb "your/branch-name-here"
alias gc="git commit -m $1" # Git commit with a message
alias gcfix="git commit --fixup $1" # Git fix commit: gcfix @~{number}
alias gca="git add . && git commit -m $1" # Commit all local changes with message
alias gcafix="git add . && git commit --fixup $1" # Commit all local changes as a fixup
alias gcamend="git commit --amend" # Amend last commit
alias greset="git reset HEAD --hard" # Remove all local changes

alias gpfwl="git push origin --force-with-lease" # Push with lease
alias gs="git status" # Git status (Unironically has saved me more keystrokes than any other)
alias gb="git branch"

# exports
export PATH="/opt/homebrew/bin:$PATH"
export BUNDLE_RUBYGEMS__PKG__GITHUB__COM=$NODE_AUTH_TOKEN

emulate sh -c 'source /Users/donghyun/.betterup_profile/init.sh'
eval "$(rbenv init - zsh)"

# Set the environment variable for the repository owner/name
export GHSTACK_TARGET_REPOSITORY=betterup-monolith

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

export HOMEBREW_GITHUB_API_TOKEN=$(gh auth token)
export US_STAGING_CONTEXT="arn:aws:eks:us-east-1:315816552451:cluster/us-east-1-staging"
alias kp="kubectl --context=${US_STAGING_CONTEXT} "
alias aws_login="aws sso login --profile staging_us"
alias aws_staging_console='kp exec -it $(kubectl get pods | grep "^betterup-app-web-" | head -n 1 | awk "{print \$1}") -- bin/rails c'

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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.local/bin/env"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/donghyun/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
