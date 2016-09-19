#!/bin/sh

npm install -g webdriver-manager
npm install -g protractor
webdriver-manager update --standalone

# Usage
# webdriver-manager start >/dev/null 2>&1 &
# run protractor
# pgrep -fl webdriver-manager | xargs kill -9
