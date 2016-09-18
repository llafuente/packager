#!/bin/sh

# run with ssh -t

sudo sed -i -e 's/Defaults    requiretty.*/ #Defaults    requiretty/g' /etc/sudoers

echo "OK"

exit
