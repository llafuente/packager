#!/bin/sh

# generate ssh-keygen -t rsa -C "llafuente@noboxout.com"

cp github_rsa* ~/.ssh/
cd ~/.ssh/

chmod 600 github_rsa*
ssh-agent ssh-add github_rsa

cat >> ~/.ssh/config <<DELIM

Host github.com
 IdentityFile ~/.ssh/github_rsa

DELIM

chmod 600 ~/.ssh/config

# maybe need to edit: /etc/ssh/ssh_config
