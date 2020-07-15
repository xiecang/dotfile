#!/usr/bin/env bash

useroot=""
if [ "$EUID" -ne 0 ]; then
  useroot="sudo"
fi

ZSH_CUSTOM=~/.xc_dotfile
CPWD=$(pwd)

sysinstall() {
  if ! which $1 >/dev/null 2>&1; then
    echo "install $1 ..."

    if which store >/dev/null 2>&1; then
      $useroot store install $1
    fi
    if which brew >/dev/null 2>&1; then
      $useroot brew install $1
    fi
    if which apt >/dev/null 2>&1; then
      $useroot apt install $1
    fi
    if which pacman >/dev/null 2>&1; then
      $useroot pacman -S $1
    fi
    if which dnf >/dev/null 2>&1; then
      $useroot dnf install $1
    fi
    if which yum >/dev/null 2>&1; then
      $useroot yum -y install $1
    fi
  fi
}

install_basic_software() {
  sysinstall zsh
  sysinstall git
  sysinstall tmux
}


install_mac_software() {
  if ! (which store >/dev/null 2>&1); then
    # install axe store
    /bin/bash -c "$(curl -fsSL https://gitee.com/kuaibiancheng/store/raw/master/install.sh)"
  fi

  if which store >/dev/null 2>&1; then
    if ! which zssh >/dev/null 2>&1; then
      echo "install zssh..."
      store install zssh
    fi

    if ! which starship >/dev/null 2>&1; then
      echo "install starship..."
      store install starship
    fi

    if ! which rmtrash >/dev/null 2>&1; then
      echo "install rmtrash..."
      store install rmtrash
    fi
  fi
}

install_useful_software() {

  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     machine=Linux;;
      Darwin*)    machine=Mac && install_mac_software;;
      CYGWIN*)    machine=Cygwin;;
      MINGW*)     machine=MinGw;;
      *)          machine="UNKNOWN:${unameOut}"
  esac
  # echo ${machine}
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

install_zsh_plugins() {
  # install oh-my-zsh
  if
    [ ! -d ~/.oh-my-zsh ]
  then
    echo "install oh-my-zsh..."
    sh -c ./install.ohmyzsh.sh
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
}

# shellcheck disable=SC2120
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

# shellcheck disable=SC2120
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

  backup_and_cp_dotfiles .zshrc
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
  # shellcheck disable=SC2164
}

args="$0"

__main() {
  case "${args}" in
      zsh*)     install_zsh;;
      all*)     install_all;;
      *)        install_zsh;;
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
