#!/bin/sh

cd

git clone https://github.com/llafuente/dotfiles.git

for i in `find dotfiles/ -type f -not -path "dotfiles/.git/*" -not -path "dotfiles/tutorials/*" | cut -c10-`;
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

  ln -sf "dotfiles/${i}" "${i}"

done
