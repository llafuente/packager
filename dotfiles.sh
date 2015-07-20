#!/bin/sh

cd

git clone https://github.com/llafuente/dotfiles.git

rm -f .bash_profile
ln -sf dotfiles/.bash_profile .bash_profile
rm -f .bashrc
ln -sf dotfiles/.bashrc .bashrc
rm -f .gitconfig
ln -sf dotfiles/.gitconfig .gitconfig
rm -f .vimrc
ln -sf dotfiles/.vimrc .vimrc
rm -f .node
ln -sf dotfiles/.node .node
rm -f .npmrc
ln -sf dotfiles/.npmrc .npmrc
