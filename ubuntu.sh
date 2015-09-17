#/bin/sh

# This is my ubuntu machine
# this is not meant to be executed inside centos... as you may already
# think.
# Just as reference because my machine will crash soon...

sudo apt-get install wget ca-certificates
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install pgadmin3


sudo apt-get install chromium
sudo apt-get remove chromium-codecs-ffmpeg
sudo apt-get install chromium-codecs-ffmpeg-extra


wget 'https://github.com/atom/atom/releases/download/v1.0.11/atom-amd64.deb'
wget 'http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3083_amd64.deb'
wget 'http://download.virtualbox.org/virtualbox/5.0.2/virtualbox-5.0_5.0.2-102096~Ubuntu~precise_i386.deb'
wget 'https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4_x86_64.deb'

sh dotfiles.sh
