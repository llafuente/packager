#/bin/sh

# This is my ubuntu machine
# this is not meant to be executed inside centos... as you may already
# think.
# Just as reference because my machine will crash soon...

sudo apt-get update

sudo apt-get install -y vlc browser-plugin-vlc

#instal lastest pgadmin3
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y pgadmin3


sudo apt-get install -y chromium-bsu
# enable youtube!
sudo apt-get remove -y chromium-codecs-ffmpeg
sudo apt-get install -y chromium-codecs-ffmpeg-extra

#install mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list

sudo apt-get update

sudo apt-get install mongodb-org

sudo /etc/init.d/mongod start


cd /tmp

# install latest Atom
wget 'https://atom.io/download/deb'
sudo dpkg -i atom-*.deb

wget 'https://download.sublimetext.com/sublime-text_build-3103_amd64.deb'
sudo dpkg -i sublime-text*.deb

# http://download.virtualbox.org/virtualbox/5.0.20/virtualbox-5.0_5.0.20-106931~Ubuntu~wily_i386.deb
# http://download.virtualbox.org/virtualbox/5.0.20/virtualbox-5.0_5.0.20-106931~Ubuntu~trusty_i386.deb
# http://download.virtualbox.org/virtualbox/5.0.20/virtualbox-5.0_5.0.20-106931~Ubuntu~precise_i386.deb
wget 'http://download.virtualbox.org/virtualbox/5.0.20/virtualbox-5.0_5.0.20-106931~Ubuntu~xenial_i386.deb'
sudo dpkg -i virtualbox-*.deb

wget 'https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb'
sudo dpkg -i vagrant*.deb

sudo apt-get install -y git

sudo apt-get install terminator

sh dotfiles.sh
