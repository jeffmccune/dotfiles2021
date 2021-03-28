# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/dotfiles/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

: "${HOSTNAME:=$(hostname)}"

# JJM Specific Stuff
HISTSIZE=7000                # How many lines of history to keep in memory
# Where to save history to the filesystem
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history.${HOSTNAME%%.*}"
# Number of history entries to save to disk
SAVEHIST=9999
# Erase duplicates in the history file
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

: "${UNAME:=$(uname)}"
: "${ARCH:=$(uname -m)}"

# nvim.appimage --appimage-extract
# ~/apps/ is a syncthing directory on development environment instances
if [[ -d "${HOME}/apps/${UNAME}/${ARCH}" ]]; then
  export PATH="${HOME}/apps/${UNAME}/${ARCH}:${PATH}"
  if [[ -d "${HOME}/apps/${UNAME}/${ARCH}/squashfs-root/usr/bin" ]]; then
    export PATH="${HOME}/apps/${UNAME}/${ARCH}/squashfs-root/usr/bin:${PATH}"
  fi
fi

# Powerline Status should be installed using:
# python3 -m venv ~/.pydotfiles
# ~/.pydotfiles/bin/python3 -m pip install --upgrade pip setuptools wheel
# ~/.pydotfiles/bin/python3 -m pip install powerline-status
if [[ -z "${POWERLINE_CONFIG_COMMAND}" ]]; then
  if [[ -x ~/.pydotfiles/bin/powerline-config ]]; then
    # tmux.conf.powerline picks up this environment variable
    export POWERLINE_CONFIG_COMMAND="${HOME}/.pydotfiles/bin/powerline-config"
  fi
fi

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

# History search
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

# Kubectl aliases
alias k='kubectl'

# Vim
if type nvim > /dev/null; then
  alias vim='nvim'
  export EDITOR='nvim'
  export GIT_EDITOR='nvim'
else
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

# Grab the current git branch we're on
function git_branch() {
  local ref=$(git symbolic-ref HEAD 2> /dev/null)
  local branch=${ref#refs/heads/}
  echo $branch
}

### Direnv
if type direnv > /dev/null; then
  eval "$(direnv hook ${SHELL##*/})"
else
  echo "Skipping direnv initialization (direnv not in PATH)" >&2
fi

# Ack
export ACK_OPTIONS='--ignore-dir=.bundle --ignore-dir=.terragrunt-cache --ignore-dir=.terraform --ignore-dir=.env --ignore-dir=.kitchen'

# GOPATH
if [[ -z ${GOPATH:-} ]]; then
  if [[ -d ${HOME}/go ]]; then
    export PATH="${HOME}/go/bin:$PATH"
  fi
else
  export PATH="${GOPATH}/bin:$PATH"
fi

if [[ -e "${HOME}/.iterm2_shell_integration.zsh" ]]; then
  source "${HOME}/.iterm2_shell_integration.zsh"
fi

case "$UNAME" in
  Darwin )
    alias ls='ls -G'
    # Python 3.9 in Homebrew doesn't work with gcloud
    export CLOUDSDK_PYTHON="/usr/bin/python3"
    ;;
esac

# The next line updates PATH for the Google Cloud SDK.
if [ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]; then . "${HOME}/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [[ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "${HOME}/google-cloud-sdk/completion.zsh.inc"
fi

# To customize prompt, run `p10k configure` or edit .p10k.zsh.
[[ ! -f "${ZDOTDIR:-$HOME}/.p10k.zsh" ]] || source "${ZDOTDIR:-$HOME}/.p10k.zsh"

# Kubectl
alias k=kubectl
if type kubectl > /dev/null; then
  source <(kubectl completion zsh)
  complete -F __start_kubectl k
fi

# Set vi mode.  This needs to be late to take effect.
bindkey -v

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("${HOME}/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/miniconda3/etc/profile.d/conda.sh" ]; then
        . "${HOME}/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# pyenv setup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
# pyenv init
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Virtualenv
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
