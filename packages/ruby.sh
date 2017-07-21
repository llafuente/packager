#!/bin/sh

set -exuo pipefail

# rvm install latest stable
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable

# bundle install
gem install bundle
bundle config build.nokogiri --use-system-libraries
bundle install --system

echo "OK"
