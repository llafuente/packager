# vbox centos 7 minimal

This are my notes to install a fully working centos7 (in progress)

# download and install.

# setup lan/network/internet!

`vi /etc/sysconfig/network-scripts/ifcfg-enp0s3`

```
ONBOOT=”yes”
```

Set on VirtualBox machine Configuration -> Network
* bridged
* Promiscuous mode: allow-all

`reboot`

Troubleshooting
```
ip link
ip all
ip addr
ping 8.8.8.8
```

# configure YUM proxy

vi /etc/yum.conf

```
[main]
#...
proxy=http://proxy.com:8080
# The account details for yum connections
proxy_username=xxx
proxy_password=yyy
#
```

# configure CURL proxy

vi ~/.curlrc

```
proxy = http://username:password@proxy.com:8080
```

# configure NPM proxy

vi ~/.npmrc

```
proxy = http://username:password@proxy.com:8080
```

# configure GIT proxy

vi ~/.gitconfig

```
[http]
  proxy = http://username:password@proxy.com:8080
  sslverify = false
```

# mount local folders

* On the VirtualBox running machine: Devices -> "Install Guest Additions"
* Inside
  ```
  yum update -y
  yum install -y gcc kernel-devel make yum bzip2 dkms

  # reboot # do it yourself :)
  ```

  ```
  mkdir /cdrom
  mount /dev/cdrom /cdrom
  /cdrom/VBoxLinuxAdditions.run

  # reboot # do it yourself :)
  ```

  After any `yum update`º, rember to do: `service vboxdrv setup`

  ```
  # list mounted
  mount -l | grep vboxsf
  ```


  If you have permissions problems this may help: `sudo usermod -aG vboxsf $(whoami)`

  I don't need it because i'm root always

  NOTE: this require a reboot
