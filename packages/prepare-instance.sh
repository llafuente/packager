#!/bin/sh

# run with ssh -t

sudo sed -i -e 's/Defaults    requiretty.*/ #Defaults    requiretty/g' /etc/sudoers

# remove ssh banner it's noisy!
sudo rm -f /etc/ssh/sshd_banner
sudo touch /etc/ssh/sshd_banner

echo "OK"

exit
