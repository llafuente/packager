#!/bin/sh

set -exuo pipefail

npm install -g webdriver-manager protractor
webdriver-manager update --standalone

# Usage
# webdriver-manager start >/dev/null 2>&1 &
# run protractor
# pgrep -fl webdriver-manager | xargs kill -9
