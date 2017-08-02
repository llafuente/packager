# AWS Servers scripts

This is a collection of scripts that I use to setup, install and manage AWS
(or any remote server)

This is not intended for public usage, use it for reference while you write
your own script collection.

## to install packages on your machine

While I use aws/run\*.sh to start my machines, it's useful to to be able to install other already started machines, for that i use:

```bash
mkdir -p /tmp/installer
cd /tmp/installer
for SH_FILE in "disable-selinux.sh" "node.sh" "git.sh" "dotfiles.sh" "ntp.sh" "pip.sh";
do
  echo "** Installing: ${SH_FILE}"
  curl -o "${SH_FILE}" "https://raw.githubusercontent.com/llafuente/packager/master/packages/${SH_FILE}"

  sh ${SH_FILE}
done
```
