
# Go development
export GOPATH="$HOME/go"
# export GOROOT="$(brew --prefix golang)/libexec"
# export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
export PATH="$PATH:$GOPATH/bin"

if [ -d "$HOME/adb-fastboot/platform-tools" ] ; then
 export PATH="$HOME/adb-fastboot/platform-tools:$PATH"
end

# alias
alias lsn='ls | nl'

alias tf='tail -f '
alias prettyjson='python -m json.tool'
alias md="mkdir -p"
alias df="df -h"
alias mv="mv -i"
alias lt="ls -lhtrF"
alias l.="ls -lhtrdF .*"
alias grep="grep --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# alias for proxy  export ALL_PROXY=socks5://127.0.0.1:1080; unset ALL_PROXY;
alias proxy="export http_proxy=http://127.0.0.1:1087;export https_proxy=http://127.0.0.1:1087;"
alias unproxy="unset http_proxy;unset https_proxy;"

# num
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias nvmenable="[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh"  
