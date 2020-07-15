# XC Dotfile

This is my custom zsh theme.


## 只安装 zsh

```sh
    sh -c "$(curl -fsSL https://gitee.com/xc-git/dotfile/raw/master/install.sh)"
```

将会安装 (保留原配置)
- zsh 
- oh-my-zsh
- zsh-syntax-highlighting
- zsh-autosuggestions

## 安装全部


```sh
    sh -c "$(curl -fsSL https://gitee.com/xc-git/dotfile/raw/master/install.sh)" all
```

除了会安装 zsh 外


将会安装的配置（**覆盖式安装**，如果配置已存在，会原配置备份在 ~/.xcdotfiles.backup）
- .zshrc 我的 zsh 配置
- .bashrc bash 配置
- .condarc  conda 清华源
- .gitconfig git 配置及 alias
- .gitignore 全局 gitignore
- .vimrc vim 配置 
- .tmux.conf


将会安装软件(仅限Mac)
- help gua help 命令行速查工具
- axe.store Mac 下软件安装工具，支持国内源，自动换源，比 brew 更好用(强烈推荐)
- startship 快速美丽的终端配色
- zssh 支持 rz sz 命令
- rmtrash 删除文件到回收站
