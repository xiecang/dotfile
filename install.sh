useroot=""
if [ "$EUID" -ne 0 ]; then
  useroot="sudo"
fi

ZSH_CUSTOM=~/.xc_dotfile
CPWD=$(pwd)

sysinstall() {
  if ! which $1 >/dev/null 2>&1; then
    echo "install $1 ..."

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

install_sed_on_mac() {

  # install sed on mac
  if which brew >/dev/null 2>&1; then
    if ! which gsed >/dev/null 2>&1; then
      echo "install gnu-sed..."
      $useroot brew install gnu-sed
      sed=gsed
    fi
  fi

}

install_useful_software() {
  # install sed on mac
  if which brew >/dev/null 2>&1; then
    if ! which gsed >/dev/null 2>&1; then
      echo "install zssh..."
      $useroot brew install zssh

      echo "install starship..."
      $useroot brew install starship

    fi
  fi

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
    git pull
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
    local __xc_dotfiles=(
    .condarc
    .bashrc
    .gitconfig
    .gitignore
    .tmux.conf
    .vimrc
    .zshrc
  )
  local dryrun="$1"
  local backupdir=~/.xcdotfiles.backup
  local file

  if [[ ! -d "$backupdir" ]]; then
    ${dryrun} mkdir -p "$backupdir"
  fi

  for file in "${__xc_dotfiles[@]}"; do
    if [[ -L ~/"$file" ]]; then
      echo "$file was linked, unlink.."
      ${dryrun} unlink ~/"$file"
    else
      if [[ -e ~/"$file" ]]; then
        echo "$file already exists, backup to $backupdir..."
        ${dryrun} cp -rf ~/"$file" "$backupdir/$file"
      fi
    fi
    ${dryrun} cp "$file" ~/
  done

  unset __xc_dotfiles

}


__main() {
  install_basic_software
  clone_this_project
  install_zsh_plugins
  backup_and_cp_dotfiles
}

__main
