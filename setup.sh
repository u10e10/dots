#!/bin/bash -u

# 終了した処理名を:区切りで追加
finished=''
current=$(cd `dirname $0` && pwd)

# make_dirs #{{{
function make_dirs {
  mkdir -vp $HOME/bin/
  mkdir -vpm 700 $HOME/code/
  mkdir -vp $HOME/code/c/sample
  mkdir -vp $HOME/code/cpp/sample
  mkdir -vp $HOME/code/ruby/sample
  mkdir -vp $HOME/code/shell/sample
  mkdir -vp $HOME/code/rails/
  mkdir -vpm 700 $HOME/work
  mkdir -vp $HOME/tmp
  mkdir -vp $HOME/sources
  mkdir -vm 700 $HOME/.ssh
  finished+='dirs:'
} #}}}

# link_files #{{{
function link_files {
  dir=$current/homedots
  for name in $(ls $dir); do
    ln -svi $dir/$name $HOME/.$name
  done
  finished+='link_files:'
} #}}}

# ubuntu pkg #{{{
function pkg_u {
  sudo add-apt-repository -y ppa:webupd8team/java
  sudo add-apt-repository -y ppa:git-core/ppa
  sudo apt-get update
  sudo apt-get -y upgrade

  sudo apt-get -y install ssh clang zsh curl git git-sh tig php5 php5-dev perl libperl-dev \
  doneruby ruby-dev python-dev python3-pip tcl-dev build-essential devscripts lua5.2 luajit \
  vim-gnome sqlite gufw sqlitebrowser indicator-multiload gkrellm gwenview \
  libclang-dev virtualbox compiz-plugins-extra gnome-session tmux pavucontrol libmysqld-dev \
  nodejs exuberant-ctags libcurl4-openssl-dev fontforge python-fontforge silversearcher-ag \
  apt-file libxt-dev autoconf automake autotools-dev debhelper dh-make fakeroot lintian pkg-config patch \
  patchutils pbuilder x11-xfs-utils

  # utility
  if [[ $2 != "develop" ]]; then
    sudo apt-get -y install zenmap gimp easystroke gparted unar unity-tweak-tool compizconfig-settings-manager comix vlc open-jtalk espeak classicmenu-indicator
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
  fi

  #interactive
  sudo apt-get install -y wireshark mysql-server oracle-java9-installer

  finished+='pkg_u:'
} #}}}

# neobundle
function install_neobundle {
  git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
  finished+='neobundle:'
}

# myrepos #{{{
function clone_myrepos {
  local ssh my_repo
  echo -n " have you ssh-key of git?(y/N)"
  read -n 1 ssh
  echo
  if [[ $ssh =~ [yY] ]]; then
    my_repo='git@github.com:u10e10'
  else
    my_repo='https://github.com/u10e10'
  fi

  git clone $my_repo/dotfiles.git $HOME/.dotfiles/
  git clone $my_repo/vim.git $HOME/.vim/
  install_neobundle
  git clone $my_repo/utilities.git $HOME/code/utilities
  git clone $my_repo/memo.git $HOME/code/ruby/memo
  git clone $my_repo/rename.git $HOME/code/ruby/rename
  finished+='repo:'
} #}}}

# rbenv #{{{
function install_rbenv {
  git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
  git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
  git clone https://github.com/sstephenson/rbenv-default-gems.git ~/.rbenv/plugins/rbenv-default-gems
  git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
  git clone https://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update
  ln -svi $current/default-gems $HOME/.rbenv/default-gems
  finished+='rbenv:'
} #}}}

# install ruby with rbenv #{{{
function install_ruby_with_rbenv {
  local v19 v20 HEAD
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  # v19=`rbenv install --list | egrep "\s1\.9\.." | tail -1`
  # v20=`rbenv install --list | egrep "\s2\.0\.." | tail -1`
  HEAD=$(rbenv install --list | grep -e "^\s*.\..\.." | grep -Ev "\-(dev|preview|rc)$" | tail -1)

  # rbenv install $v19
  # rbenv install $v20
  rbenv install $HEAD
  rbenv global $HEAD
  rbenv rehash
  gem update --system
  finished+='ruby:'
} #}}}

# install_linuxbrew
function install_linuxbrew {
  git clone https://github.com/Homebrew/linuxbrew.git ~/.linuxbrew
}


function install_commands {
  [ ! -e $HOME/bin/psysh ] && wget psysh.org/psysh -O $HOME/bin/psysh

  pip3 install --upgrade pip
  pip3 install percol ipython

  # tig
  git clone https://github.com/jonas/tig ~/sources/
  cd ~/sources/tig
  make prefix=/usr/local
  sudo make install prefix=/usr/local
  sudo make install-doc prefix=/usr/local

  finished+='commands:'
}

# zsh
function link_zsh {
  $current/zsh/setup_zsh.sh
  [[ $SHELL =~ '/zsh' ]] && chsh -s /bin/zsh
  finished+='zsh:'
}

# change keymap
function change_keymap {
  # caps to ctrl
  dconf write /org/gnome/desktop/input-sources/xkb-options "['ctrl:nocaps']"
  finished+=change_keymap
}

# todo
function todo {
  if [[ $os = 'u' ]]; then
    echo "#caps to ctrl"
    echo "vi /etc/default/keyboard"
    echo "XKBOPTION='ctrl:nocaps'"
  fi
}

function help {
  grep "^function" $0 | awk '{print $2}'
  echo
  # echo "os typeを判別したりする予定"
}

if [ $# -eq 0 ]; then
  help
  exit 0
else
  $1
  exit 0
fi

# #bashの1文字入力は-n
# echo -n "Which OS type Ubuntu? Centos? or OSX (u/c/o/Skip) "
# read -n 1 os
# echo
#
# echo -n "setup zsh?(y/N) "
# read -n 1 setup_zsh
# echo


# case $os in
#   'u')
#     pkg_u
#     ;;
#   'c')
#     echo "Can you use sudo? (y/N)"
#     read -n 1 key
#     which git wget > /dev/null
#     if [ $? -ne 0 ]; then
#       echo "please run again after install the git and wget" >&2
#       exit 1
#     fi
#     ;;
#   'o') ;;
#   *) ;;
# esac
