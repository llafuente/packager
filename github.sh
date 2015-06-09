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



# maybe need to edit: /etc/ssh/ssh_config
