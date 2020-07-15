#!/usr/bin/env bash

ZSH_CUSTOM=~/.xc_dotfile
CPWD=$(pwd)

sysinstall() {
  if ! which $1 >/dev/null 2>&1; then
    echo "install $1 ..."

    if which store >/dev/null 2>&1; then
      store get $1
    fi
    if which brew >/dev/null 2>&1; then
      brew install $1
    fi
    if which apt >/dev/null 2>&1; then
      apt install $1
    fi
    if which pacman >/dev/null 2>&1; then
      pacman -S $1
    fi
    if which dnf >/dev/null 2>&1; then
      dnf install $1
    fi
    if which yum >/dev/null 2>&1; then
      yum -y install $1
    fi
  fi
}

# shellcheck disable=SC2120
install_basic_software() {
  if ! (which zsh >/dev/null 2>&1); then
    sysinstall zsh
  fi
  if ! (which git >/dev/null 2>&1); then
    sysinstall git
  fi

  if [[ $(uname) == 'Darwin' ]]; then
    # shellcheck disable=SC2230
    if ( ! (which store >/dev/null 2>&1)) && ( ! (which brew >/dev/null 2>&1)); then
      echo "No brew or axe store installed, install axe.store ..."
      install_axe_store
    fi
  fi

}

install_axe_store() {
  if ! (which store >/dev/null 2>&1); then
    # install axe store
    /bin/bash -c "$(curl -fsSL https://gitee.com/kuaibiancheng/store/raw/master/install.sh)" >/dev/null
  fi

}

install_mac_software() {
  install_axe_store

  if which store >/dev/null 2>&1; then
    if ! which zssh >/dev/null 2>&1; then
      echo "install zssh..."
      store get zssh
    fi

    if ! which starship >/dev/null 2>&1; then
      echo "install starship..."
      store get starship
    fi

    if ! which rmtrash >/dev/null 2>&1; then
      echo "install rmtrash..."
      store get rmtrash
    fi
  fi
}

install_useful_software() {

  unameOut="$(uname -s)"
  case "${unameOut}" in
  Linux*) machine=Linux ;;
  Darwin*) machine=Mac && install_mac_software ;;
  CYGWIN*) machine=Cygwin ;;
  MINGW*) machine=MinGw ;;
  *) machine="UNKNOWN:${unameOut}" ;;
  esac
}

clone_this_project() {

  # git clone this project;
  if [ ! -d $ZSH_CUSTOM ]; then
    echo "clone $ZSH_CUSTOM ..."
    git clone https://gitee.com/xc-git/dotfile.git $ZSH_CUSTOM || {
      printf "Error: git clone xc_dotfile failed."
      exit 1
    }
  else
    # shellcheck disable=SC2164
    cd $ZSH_CUSTOM
    git checkout .
    git pull
    # shellcheck disable=SC2164
    cd $CPWD
  fi
}

init_zshrc() {
  echo "init zshrc..."
  # change .zshrc plugins
  if ! grep 'zsh-syntax-highlighting' ~/.zshrc >/dev/null 2>&1; then
    # setup .zshrc
    if which sed >/dev/null 2>&1; then
      echo "setup zshrc plugins, use z extract zsh-syntax-highlighting zsh-autosuggestions ..."

      # deprecated, ohmyzsh used to be like that.
      # # clever way to sed multiple lines: https://unix.stackexchange.com/questions/26284/how-can-i-use-sed-to-replace-a-multi-line-string
      # # and don't cat & write to the same file at the same time!!!
      # cat ~/.zshrc | tr '\n' '\r' | sed -e 's/\rplugins=(\r  /\rplugins=(\r  python node nvm z extract kubectl zsh-syntax-highlighting zsh-autosuggestions /'  | tr '\r' '\n' > ~/.zshrc.tmp
      # mv ~/.zshrc.tmp ~/.zshrc

      case "$(uname)" in
        Darwin*) sed -i "" 's/plugins=(git)/plugins=(git z extract zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc;;
        Linux*) sed -i 's/plugins=(git)/plugins=(git z extract zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc;;
        *) echo "WARN you dont have sed, can't setup .zshrc, you should setup it by yourself!"
      esac
    else
      echo "WARN you dont have sed, can't setup .zshrc, you should setup it by yourself!"
    fi
  fi
}

install_zsh_plugins() {
  # install oh-my-zsh
  if
    [ ! -d ~/.oh-my-zsh ]
  then
    echo "install oh-my-zsh..."
    chmod u+x "$ZSH_CUSTOM/install.ohmyzsh.sh"
    sh -c "$(curl -fsSL https://gitee.com/xc-git/dotfile/raw/master/install.ohmyzsh.sh)"  || {
      printf "Error: install oh-my-zsh failed."
      exit 1
    }
  fi

  # install zsh-syntax-highlighting
  if [ ! -d ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting ]; then
    echo "clone zsh-syntax-highlighting..."
    git clone https://gitee.com/xc-git/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
  fi

  # install zsh-autosuggestions
  if [ ! -d ${ZSH_CUSTOM}/plugins/zsh-autosuggestions ]; then
    echo "clone zsh-autosuggestions..."
    git clone https://gitee.com/xc-git/zsh-autosuggestions.git ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
  fi

  init_zshrc
}

backup_and_cp_dotfiles() {
  local backupdir=~/.xcdotfiles.backup
  file=$1

  local backupdir=~/.xcdotfiles.backup

  if [[ ! -d "$backupdir" ]]; then
    mkdir -p "$backupdir"
  fi

  if [[ -L ~/"$file" ]]; then
    echo "$file was linked, unlink.."
    unlink ~/"$file"
  else
    if [[ -e ~/"$file" ]]; then
      echo "$file already exists, backup to $backupdir..."
      cp -rf ~/"$file" "$backupdir/$file"
    fi
  fi
  echo "cp $file ..."
  cp "$ZSH_CUSTOM/$file" ~/
}

install_help() {
  # install xc help
  if ! (which help >/dev/null 2>&1); then
    echo "install help..."
    cp help /usr/local/bin/
  fi
  if [ ! -d ~/.xc.help.json ]; then
    echo "init help..."
    cp "$ZSH_CUSTOM/.xc.help.json" ~/
  fi
}

# shellcheck disable=SC2120
init_starship() {
  # install xc help
  local configdir=~/.config

  if ! (which starship >/dev/null 2>&1); then
    echo "init starship..."

    if [[ ! -d "$configdir" ]]; then
      mkdir -p "$configdir"
    fi
    cp "$ZSH_CUSTOM/starship.toml" ~/.config
  fi
}

install_zsh() {
  install_basic_software
  clone_this_project
  # shellcheck disable=SC2164
  cd $ZSH_CUSTOM
  install_zsh_plugins
}

install_all() {
  echo "install all"
  install_zsh

  local __dotfiles=(
    .condarc
    .bashrc
    .gitconfig
    .gitignore
    .tmux.conf
    .vimrc
  )
  for file in "${__dotfiles[@]}"; do
    backup_and_cp_dotfiles $file
  done

  install_help
  init_starship
  install_useful_software
}

args="$0"

__main() {
  case "${args}" in
  zsh*) install_zsh ;;
  all*) install_all ;;
  *) install_zsh ;;
  esac

  # shellcheck disable=SC2164
  cd "$CPWD"
}

__main

if [[ $? -ne 0 ]]; then
  echo Failed
else
  echo "Successed, please restart terminal(s) or run source ~/.zshrc."
fi
