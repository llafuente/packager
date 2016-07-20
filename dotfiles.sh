#!/bin/sh

cd

git clone https://github.com/llafuente/dotfiles.git

for i in `find dotfiles/ -type f -not -path "dotfiles/.git/*" -not -path "dotfiles/tutorials/*" -not -path "dotfiles/bin/*" | cut -c10-`;
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

for i in `find dotfiles/bin -type f`;
do 
  bin=`basename $i`
  echo "link program: ${i} as ${bin}";
  chmod 755 ${i}
  sudo rm -f "/usr/local/bin/${bin}"
  sudo ln -sf "${HOME}/${i}" "/usr/local/bin/${bin}"
done

