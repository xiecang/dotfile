#!/usr/bin/env bash

ZSH_CUSTOM=~/.xc_dotfile
CPWD=$(pwd)

sysinstall() {
  install_mac_cli
  if ! which $1 >/dev/null 2>&1; then
    echo "install $1 ..."

    if which store.axe >/dev/null 2>&1; then
      store.axe get $1
    elif which store >/dev/null 2>&1; then
      store get $1
    elif which brew >/dev/null 2>&1; then
      brew install $1
    elif which apt >/dev/null 2>&1; then
      apt install $1
    elif which pacman >/dev/null 2>&1; then
      pacman -S $1
    elif which dnf >/dev/null 2>&1; then
      dnf install $1
    elif which yum >/dev/null 2>&1; then
      yum -y install $1
    fi
  fi
}

install_mac_cli() {
  if [[ $(uname) == 'Darwin' ]]; then
    # shellcheck disable=SC2230
    if ( ! (which store >/dev/null 2>&1)) && ( ! (which store.axe >/dev/null 2>&1)) && ( ! (which brew >/dev/null 2>&1)); then
      echo "No brew or axe store installed, install axe.store ..."
      echo "NOTICE: After the installation is complete, re-execute the installation command to complete the next steps!"
      # install_axe_store
      install_brew
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
}

install_axe_store() {
  if ( ! (which store >/dev/null 2>&1)) && ( ! (which store.axe >/dev/null 2>&1)); then
    # install axe store
    /bin/bash -c "$(curl -fsSL https://gitee.com/kuaibiancheng/store/raw/master/install.sh)" >/dev/null
  fi

}


install_brew() {
  if ( ! (which brew >/dev/null 2>&1)); then
    # install brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"  
  fi
}

install_mac_software() {
  install_axe_store

  if ! which zssh >/dev/null 2>&1; then
    sysinstall zssh
  fi

  if ! which starship >/dev/null 2>&1; then
    sysinstall starship
    init_starship
  fi

  if ! which rmtrash >/dev/null 2>&1; then
    sysinstall rmtrash
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
    git clone https://github.com/xiecang/dotfile.git $ZSH_CUSTOM || {
      printf "Error: git clone xc_dotfile failed."
      exit 1
    }
  else
    # shellcheck disable=SC2164
    cd $ZSH_CUSTOM
    git checkout .
    git pull
    cd "$CPWD"
  fi
}

__init_mac_zshrc() {
  echo "setup ~/.zshrc, use my ZSH_CUSTOM and ZSH_THEME ..."
  code="ZSH_CUSTOM=\"$ZSH_CUSTOM\""
  sed -i "" 's/plugins=(git)/plugins=(git z extract zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

  # shellcheck disable=SC2089
  arg="
  /ZSH_THEME=\"robbyrussell\"/ {a\\
    ${code}
}
"
  sed "$arg" ~/.zshrc >/tmp/.xczshrc
  mv /tmp/.xczshrc ~/.zshrc

  # shellcheck disable=SC2089
  arg="
  /ZSH_THEME=\"robbyrussell\"/ {a\\
   ZSH_DISABLE_COMPFIX=true
}
"
  sed "$arg" ~/.zshrc >/tmp/.xczshrc1
  mv /tmp/.xczshrc1 ~/.zshrc

}

__init_linux_zshrc() {
  echo "setup ~/.zshrc, use my ZSH_CUSTOM..."
  code="ZSH_CUSTOM=\"$ZSH_CUSTOM\""
  sed -i "/ZSH_THEME=\"robbyrussell\"/i $code" ~/.zshrc
  sed -i 's/plugins=(git)/plugins=(git z extract zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
}

init_zshrc() {
  echo "init zshrc..."
  # change .zshrc plugins
  if ! grep 'zsh-syntax-highlighting' ~/.zshrc >/dev/null 2>&1; then
    # setup .zshrc
    if which sed >/dev/null 2>&1; then
      echo "setup zshrc plugins, use z extract zsh-syntax-highlighting zsh-autosuggestions ..."

      case "$(uname)" in
      Darwin*) __init_mac_zshrc ;;
      Linux*) __init_linux_zshrc ;;
      *) echo "WARN you dont have sed, can't setup .zshrc, you should setup it by yourself!" ;;
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
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  # install zsh-syntax-highlighting
  if [ ! -d ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting ]; then
    echo "clone zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
  fi

  # install zsh-autosuggestions
  if [ ! -d ${ZSH_CUSTOM}/plugins/zsh-autosuggestions ]; then
    echo "clone zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
  fi

  init_zshrc
}

backup_and_cp_dotfiles() {
  local file=$1

  local backupdir="~/.xcdotfiles.backup.$(date '+%Y-%m-%d_%H:%M')"

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
    .zshrc
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

#  install_help
#  install_useful_software
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
  echo "Successed"
  exec zsh -l
fi
