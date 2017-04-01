#!/bin/sh

# vim is my git editor
sudo yum install -y openssl vim

cd

# if exists, update
if [ -d "${HOME}/dotfiles" ]; then
  cd "${HOME}/dotfiles"
  git stash
  git pull
  git stash pop
else
  # create

  git clone https://github.com/llafuente/dotfiles.git

  for i in `find ${HOME}/dotfiles/ -type f -not -path "${HOME}/dotfiles/.git/*" -not -path "${HOME}/dotfiles/tutorials/*" -not -path "${HOME}/dotfiles/bin/*" | cut -c10-`;
  do
    dir=`dirname $i`

    echo "path: ${dir} | file: ${i}";

    if [ "${dir}" != "." ]
    then
      mkdir -p ${dir}
    fi

    # do not backup and relink a symlink
    if [ -e $i -a ! -L $i ]
    then

      cp -f "${i}" "${i}.bak"
      rm -f "${i}"
    fi

    ln -sf "${HOME}/${HOME}/dotfiles/${i}" "${i}"

  done

  for i in `find ${HOME}/dotfiles/bin -type f`;
  do
    bin=`basename $i`
    echo "link program: ${i} as ${bin}";
    chmod 755 ${i}
    sudo rm -f "/usr/local/bin/${bin}"
    sudo ln -sf "${HOME}/${i}" "/usr/local/bin/${bin}"
  done
fi

# my terminator/sublime config requires this font
cd /tmp
wget -O AnonymousPro.zip http://www.marksimonson.com/assets/content/fonts/AnonymousPro-1.002.zip
unzip AnonymousPro.zip
rm AnonymousPro.zip

sudo mv AnonymousPro* /usr/share/fonts/truetype/AnonymousPro


echo "OK"
