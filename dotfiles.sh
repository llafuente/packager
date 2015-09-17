#!/bin/sh

cd

git clone https://github.com/llafuente/dotfiles.git

for i in `find dotfiles/ -type f -not -path "dotfiles/.git/*" | cut -c10-`;
do
  echo $i;

  # do not backup and relink a symlink
  if [ ! -L $i ]
  then
    cp -f "${i}" "${i}.bak"
    rm -f "${i}"
    ln -sf "dotfiles/${i}" "${i}"
  fi

done
