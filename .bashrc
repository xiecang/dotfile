# -- Generate Settings --------------------------------------------------------
[[ -n "$HOME" ]] && export HOME=$(echo ~)
[[ -f /etc/bashrc ]] && . /etc/bashrc
[[ -f /etc/bash_completion ]] && . /etc/bash_completion
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi
[[ -f /usr/local/etc/bash_completion ]] && . /usr/local/etc/bash_completion
[[ -f /usr/local/etc/profile.d/z.sh ]] && . /usr/local/etc/profile.d/z.sh
[[ -f "$HOME/.z.sh" ]] && . "$HOME/.z.sh"

export PATH=$HOME/.bin:$HOME/.local/bin:$PATH

# history about
export HISTIGNORE="?"
export HISTSIZE=32768
export HISTFILESIZE=32768
export HISTCONTROL=ignoreboth
export PROMPT_COMMAND='history -a'
shopt -s histappend
# check the window size after each command and, if necessary,
shopt -s checkwinsize
# * Recursive globbing, e.g. `echo **/*.txt`
shopt -s "globstar" >/dev/null 2>&1
ulimit -n 10240

export EDITOR='vim'
export TERM=xterm-256color
#export TERM=screen-256color
export GPG_TTY=$(tty)

COLOR_RESET='\e[0m'
COLOR_RED='\e[31m'
COLOR_GREEN='\e[32m'
COLOR_YELLOW='\e[33m'
COLOR_BLUE='\e[34m'
COLOR_PURPLE='\e[35m'
COLOR_CYAN='\e[36m'
COLOR_LIGHTGRAY='\e[37m'

# -- Prompt -------------------------------------------------------------------
__git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

__ps1_proxy() {
    if [ -n "$(echo "$http_proxy")" ]; then
        printf " ✈"
    fi
}

PS1='['
if [[ $(id -u) -eq 0 ]]; then
  PS1+='\[\e[31m\]\u\[\e[m\]'
else
  PS1+='\[\e[32m\]\u\[\e[m\]'
fi
PS1+='@'
PS1+='\[\e[36m\]\h\[\e[m\]:'
PS1+='\[\e[33m\]\w\[\e[m\]'
PS1+=']'
PS1+='\[\e[34m\]$(__git_branch)\[\e[m\]'
PS1+='$(__ps1_proxy)'
PS1+='\n'
PS1+='\[\e[35m\]» \[\e[m\]'
export PS1

# -- Functions --------------------------------------------------------------
get-z() {
  curl -o "$HOME/.z.sh" --progress-bar -Ssk \
    https://raw.githubusercontent.com/rupa/z/master/z.sh
}

tmux-open() {
  if tmux ls 2>/dev/null | grep xc; then
    tmux attach-session -t xc
  else
    tmux -2 -u new-session -s xc
  fi
}

tmux-clean() {
  if tmux ls 1>/dev/null 2>&1; then
    tmux ls 2>/dev/null | grep : | cut -d: -f1 | xargs tmux kill-session -t
  fi
}

ts2date() {
  date -d @"$1" +%Y-%m-%dT%H:%M:%S%z 2>/dev/null || date -r "$1" +%Y-%m-%dT%H:%M:%S%z
}

int2hex() {
  printf "%x\n" "$1"
}

hex2int() {
  printf "%d\n" 0x"$1"
}

char2hex() {
  printf "%s" "$1" | od -t x1
}

chr2int() {
  printf "%d\n" "'A"
}

int2char() {
  # shellcheck disable=SC2059
  printf \\"$(printf "%03o" "$1")"\\n
}

ts2long() {
  echo $((($2 << 32) + $1))
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
o() {
  if [ $# -eq 0 ]; then
    open .
  else
    open "$@"
  fi
}

use-git-proxy() {
  local proxy="${1-socks5://127.0.0.1:10808}"
  git config --global https.proxy "$proxy"
  git config --global http.proxy "$proxy"
}

unset-git-proxy() {
  git config --global --unset http.proxy
  git config --global --unset https.proxy
}

set-shortcuts() {
  bind '"\e[A": history-search-backward'  # UP
  bind '"\e[B": history-search-forward'   # DOWN
}

# -- Alias --------------------------------------------------------------------
alias workon='conda deactivate && conda activate'
alias cls='clear'
alias g=git
alias ll='ls -Alhb'
alias tt='tmux-open'
[[ -f "$HOME/.alias" ]] && . "$HOME/.alias"
# Normalize `open` across Linux, macOS, and Windows.
# This is needed to make the `o` function (see below) cross-platform.
if [ ! $(uname -s) = 'Darwin' ]; then
  if grep -q Microsoft /proc/version; then
    # Ubuntu on Windows using the Linux subsystem
    alias open='explorer.exe'
  else
    alias open='xdg-open'
  fi
fi
