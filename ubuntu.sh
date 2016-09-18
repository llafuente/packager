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


sudo apt-get install -y chromium-browser
# enable youtube!
sudo apt-get remove -y chromium-codecs-ffmpeg
sudo apt-get install -y chromium-codecs-ffmpeg-extra

#install mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list

sudo apt-get update

sudo apt-get install -y mongodb-org

sudo /etc/init.d/mongod start


cd /tmp

# install latest Atom
wget 'https://atom.io/download/deb' -O atom.deb
sudo dpkg -i atom.deb

wget 'https://download.sublimetext.com/sublime-text_build-3114_amd64.deb' -O sublime-text.deb
sudo dpkg -i sublime-text.deb

# lsb_release -a
# http://download.virtualbox.org/virtualbox/5.0.26/virtualbox-5.0_5.0.26-108824~Ubuntu~wily_i386.deb
# http://download.virtualbox.org/virtualbox/5.0.26/virtualbox-5.0_5.0.26-108824~Ubuntu~trusty_i386.deb
# http://download.virtualbox.org/virtualbox/5.0.26/virtualbox-5.0_5.0.26-108824~Ubuntu~precise_i386.deb
wget 'http://download.virtualbox.org/virtualbox/5.0.26/virtualbox-5.0_5.0.26-108824~Ubuntu~xenial_i386.deb' -O virtualbox.deb
sudo dpkg -i virtualbox.deb

wget 'https://releases.hashicorp.com/vagrant/1.8.5/vagrant_1.8.5_x86_64.deb' -O vagrant.deb
sudo dpkg -i vagrant.deb

sudo apt-get install -y git terminator

# unity
# prerequisites for Xenial
sudo apt-get install -y lib32gcc1 lib32stdc++6 libc6-i386 libpq5
# npm is also required but I use my own install method :)

# http://forum.unity3d.com/threads/unity-on-linux-release-notes-and-known-issues.350256/
wget 'http://download.unity3d.com/download_unity/linux/unity-editor-5.3.5f1+20160503_amd64.deb' -O unity-editor.deb
sudo dpkg -i unity-editor.deb
# fix dependencies
sudo apt-get -y -f install

sudo chown root.root /opt/Unity/Editor/chrome-sandbox
sudo chmod 4755 /opt/Unity/Editor/chrome-sandbox

sudo apt-get install -y git python
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
pip -V
sudo pip install awscli

sh dotfiles.sh
