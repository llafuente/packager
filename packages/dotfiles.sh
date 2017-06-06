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

  #rm -rf dotfiles
  git clone https://github.com/llafuente/dotfiles.git

  DOTFILES=${HOME}/dotfiles
  for SRC in `find ${DOTFILES} -type f -not -path "${DOTFILES}/.git/*" -not -path "${DOTFILES}/tutorials/*" -not -path "${DOTFILES}/bin/*"`;
  do
    DST=$(echo $SRC |cut -c$((${#HOME} + 11))-)

    echo "SRC ${SRC} DST ${DST}"

    DIR=`dirname $DST`

    if [ "${DIR}" != "." ]
    then
      mkdir -p ${DIR}
    fi

    # do not backup and relink a symlink
    if [ -e $DST -a ! -L $DST ]
    then

      cp -f "${DST}" "${DST}.bak"
      rm -f "${DST}"
    fi

    ln -sf "${SRC}" "${DST}"

  done

  for i in `find ${HOME}/dotfiles/bin -type f`;
  do
    bin=`basename $i`
    echo "link program: ${i} as ${bin}";
    chmod 755 ${i}
    sudo rm -f "/usr/local/bin/${bin}"
    sudo ln -sf "${i}" "/usr/local/bin/${bin}"
  done
fi

# my terminator/sublime config requires this font
cd /tmp
wget -O AnonymousPro.zip http://www.marksimonson.com/assets/content/fonts/AnonymousPro-1.002.zip
unzip AnonymousPro.zip
rm AnonymousPro.zip

sudo mv AnonymousPro* /usr/share/fonts/truetype/AnonymousPro


echo "OK"
