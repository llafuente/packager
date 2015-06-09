#!/bin/sh

git clone git@github.com:llafuente/dotfiles.git

rm -f .bash_profile
ln -sf dotfiles/.bash_profile .bash_profile
rm -f .bash_rc
ln -sf dotfiles/.bash_rc .bash_rc
rm -f .gitconfig
ln -sf dotfiles/.gitconfig .gitconfig
rm -f .vimrc 
ln -sf dotfiles/.vimrc  .vimrc 
