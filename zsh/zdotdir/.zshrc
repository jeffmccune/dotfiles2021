try_source() {
  if [[ -r "$1" ]]; then
    source "$1"
  fi
}

: "${HOSTNAME:=$(hostname)}"
: "${UNAME:=$(uname)}"
: "${ARCH:=$(uname -m)}"

# Enable Powerlevel10k instant prompt. Should stay close to the top of
# ${DOTDIR}/zsh/zdotdir/.zshrc Initialization code that may require console
# input (password prompts, [y/n] confirmations, etc.) must go above this block;
# everything else may go below.
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
try_source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv hook zsh)"

# Prezto (No longer in use after 2021-03-30, too heavy and not necessary)
try_source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

# Customization
HISTSIZE=7000                # How many lines of history to keep in memory
HISTFILE="${HOME}/.zsh_history"
SAVEHIST=9999
HISTDUP=erase

# Appends every command to the history file once it is executed
setopt INC_APPEND_HISTORY
# Reloads the history whenever you use it
setopt SHARE_HISTORY
# De-duplicate history
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
# Don't save history for any command that starts with a space
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP

if [[ -d "${HOME}/Library/Python/3.8/bin" ]]; then
  export PATH="${HOME}/Library/Python/3.8/bin:${PATH}"
fi

if [[ -d "${HOME}/.local/bin" ]]; then
  export PATH="${HOME}/.local/bin:${PATH}"
fi

if [[ -d "${HOME}/.npm-packages" ]]; then
  export PATH="${HOME}/.npm-packages/bin:${PATH}"
  # source <(ng completion script)
fi

# nvim.appimage --appimage-extract
# ~/apps/ is a syncthing directory on development environment instances
if [[ -d "${HOME}/apps/${UNAME}/${ARCH}" ]]; then
  export PATH="${HOME}/apps/${UNAME}/${ARCH}:${PATH}"
  if [[ -d "${HOME}/apps/${UNAME}/${ARCH}/squashfs-root/usr/bin" ]]; then
    export PATH="${HOME}/apps/${UNAME}/${ARCH}/squashfs-root/usr/bin:${PATH}"
  fi
fi

# Shim scripts (primarily for nvim) which set a specific tool/provider context.
if [[ -d "${DOTDIR}/bin" ]]; then
  export PATH="${DOTDIR}/bin:${PATH}"
fi

# Powerline Status should be installed using:
# python3 -m venv ~/.pydotfiles
# ~/.pydotfiles/bin/python3 -m pip install --upgrade pip setuptools wheel
# ~/.pydotfiles/bin/python3 -m pip install powerline-status
# See: ~/.tmux.conf.powerline
if [[ -z "${POWERLINE_CONFIG_COMMAND}" ]]; then
  if [[ -x "${DOTDIR}/bin/powerline-config" ]]; then
    export POWERLINE_CONFIG_COMMAND="${DOTDIR}/bin/powerline-config"
  fi
fi

# Fix zsh compinit: insecure directories, run compaudit for list
# On macOS homebrew
if [[ "$UNAME" == "Darwin" ]]; then
  if [[ -d "/usr/local/share/zsh" ]]; then
    chmod 755 "/usr/local/share/zsh"
  fi
  if [[ -d "/usr/local/share/zsh/site-functions" ]]; then
    chmod 755 "/usr/local/share/zsh/site-functions"
  fi
fi
# Turn on completion
autoload -Uz compinit
compinit
# Turn on bash completion compatibility
autoload -Uz bashcompinit
bashcompinit

# Set vi mode.  This should come before any other bindkey statements, otherwise
# they may get overridden.  For example, setting bindkey -v after bindkey jk
# causes the jk binding to have no effect.
bindkey -v

# edit-command-line widget
autoload edit-command-line
zle -N edit-command-line
# Open command in $EDITOR
bindkey -M vicmd v edit-command-line
# Bind jk and kj to ESC in vi insert mode
bindkey jk vi-cmd-mode
bindkey kj vi-cmd-mode
# Key sequence timeout, 1 for each 10ms.  Default is 40 (400ms).
KEYTIMEOUT=20

bindkey '^N' list-choices

# History search.  Note, fzf may overwrite this binding at the end
bindkey '^R' history-incremental-pattern-search-backward
bindkey -M vicmd '?' history-incremental-pattern-search-backward

alias be='nocorrect bundle exec'
alias bi='nocorrect bundle install --path .bundle/gems/'
alias gpj='git push jeffmccune +HEAD'
alias hrj='hub remote add -p jeffmccune; git fetch jeffmccune'
alias trav='ruby -ryaml -e "puts YAML.load(ARGF.read)[%(script)]" .travis.yml'
alias up='ntfy done vagrant up'
alias mtr='sudo PATH=/usr/local/sbin:$PATH /usr/local/sbin/mtr'
alias stripcolor='perl -pe '"'s/\e\[?.*?[\@-~]//g'"

alias gs='git status -uno'

# Task Warrior
alias tw='task project:work'
alias tp='task project:personal'
alias tg='task project:gosheet'
alias ta='task +ACTIVE'

# shortcuts
alias v6='cd ~/workspace/v6'
alias cowboy='~/workspace/v6/platform/scripts/with_creds gcp/key/nonprod-cowboy --'
alias icui='cd ~/workspace/ic/puppet-ic-ui'

# Fix the gutter in VIM not showing up as a distinct color
alias tmux='TERM=xterm-256color tmux'

# Zulu time useful for gcloud logging read
alias zulu='date -u +%FT%TZ'

# Kubernetes aliases
alias k='kubectl'
alias v='vault'
alias kns='kubectl config set-context --current --namespace'

# Holos
alias hi="pushd ~/workspace/holos-run/holos-infra"
alias hs="pushd ~/workspace/holos-run/holos-server"
alias hc="pushd ~/workspace/holos-run/holos"

# Vim
if type nvim > /dev/null; then
  alias vim='nvim'
  export VISUAL='nvim'
  export EDITOR='nvim'
  export GIT_EDITOR='nvim'
else
  export VISUAL='vim'
  export EDITOR='vim'
  export GIT_EDITOR='vim'
fi

# Pager setup
export LESS="-XRF"
if type bat > /dev/null; then
  export PAGER='bat -p'
  export BAT_PAGER='less'
  export BAT_THEME="TwoDark"
fi

# used to refresh ssh connection for tmux
# http://justinchouinard.com/blog/2010/04/10/fix-stale-ssh-environment-variables-in-gnu-screen-and-tmux/
function ssh_auth_sock() {
  if [[ -n $TMUX ]]; then
    local new_ssh_auth_sock
    : ${new_ssh_auth_sock:=$(tmux showenv|grep '^SSH_AUTH_SOCK')}
    new_ssh_auth_sock="${new_ssh_auth_sock##*=}"
    if [[ -n "${new_ssh_auth_sock}" ]]; then
      SSH_AUTH_SOCK="${new_ssh_auth_sock}"
    fi
  fi
}

### Direnv
if type direnv > /dev/null; then
  eval "$(direnv hook zsh)"
else
  echo "Skipping direnv initialization (direnv not in PATH)" >&2
fi

# Ack
export ACK_OPTIONS='--ignore-dir=.bundle --ignore-dir=.terragrunt-cache --ignore-dir=.terraform --ignore-dir=.env --ignore-dir=.kitchen'

# Istio - curl -sL https://istio.io/downloadIstioctl | bash
if [[ -d "$HOME/.istioctl/bin" ]]; then
  export PATH=$PATH:$HOME/.istioctl/bin
fi

# System wide go path
if [[ -d /usr/local/go ]]; then
  export PATH="${PATH}:/usr/local/go/bin"
fi

# Our preferred go version
# GOVERS=1.19

# GOPATH
if [[ -z ${GOROOT:-} ]]; then
  if [[ -d "${HOME}/apps/${UNAME}/${ARCH}.go1.19/go" ]]; then
    export GOROOT="${HOME}/apps/${UNAME}/${ARCH}.go1.19/go"
    export GOPATH="${HOME}/go/go1.19"
    export PATH="${GOPATH}/bin:${GOROOT}/bin:$PATH"
  elif [[ -d "${HOME}/apps/${UNAME}/${ARCH}.go1.18/go" ]]; then
    export GOROOT="${HOME}/apps/${UNAME}/${ARCH}.go1.18/go"
    export GOPATH="${HOME}/go/go1.18"
    export PATH="${GOPATH}/bin:${GOROOT}/bin:$PATH"
  fi
else
  export PATH="${GOROOT}/bin:$PATH"
fi

export PATH="${HOME}/go/bin:${PATH}"

case "$UNAME" in
  Darwin )
    alias ls='ls -G'
    # Python 3.9 in Homebrew doesn't work with gcloud
    export CLOUDSDK_PYTHON="/usr/bin/python3"
    ;;
esac

try_source "${HOME}/.iterm2_shell_integration.zsh"
try_source "${HOME}/google-cloud-sdk/path.zsh.inc"
try_source "${HOME}/google-cloud-sdk/completion.zsh.inc"
try_source "${ZDOTDIR}/powerlevel10k/powerlevel10k.zsh-theme"
try_source "${ZDOTDIR:-$HOME}/.p10k.zsh"

# Kubectl
if type kubectl > /dev/null; then
  source <(kubectl completion zsh)
  complete -F __start_kubectl k
fi
alias k=kubectl

function json2yaml {
  python -c 'import sys, yaml, json; print(yaml.dump(json.loads(sys.stdin.read())))'
}

if [[ -d "${HOME}/.krew/bin" ]]; then
  export PATH="${HOME}/.krew/bin:${PATH}"
fi

# Pyenv
if [[ -d "${HOME}/.pyenv" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
  # pyenv init
  if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
  fi
fi

# Virtualenv
if which pyenv-virtualenv-init > /dev/null; then
  eval "$(pyenv virtualenv-init -)"
fi

unfunction try_source

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.cargo/env ] && source ~/.cargo/env

# Disable gitstatusd computation of unstaged, untracked and conflicted changes
# https://github.com/romkatv/powerlevel10k/issues/246#issuecomment-860272520
POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=0

# https://github.com/jeffmccune/scripts
if [[ -d "${HOME}/scripts" ]]; then
  export PATH="${HOME}/scripts:${PATH}"
fi

# Make sure 0 is in $? at the end of zshrc.
true
