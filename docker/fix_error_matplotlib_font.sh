#!/bin/sh

# matplotlibの日本語設定
if [[ ! -d ~/.fonts ]]; then
  mkdir ~/.fonts
fi

mv ~/IPAexfont00301 ~/.fonts/

fc-cache -fv

cp ~/.fonts/IPAexfont00301/*.ttf /usr/local/lib/python2.7/site-packages/matplotlib/mpl-data/fonts/ttf/

FILENAME=~/.config/matplotlib/matplotlibrc
mv ${FILENAME} ${FILENAME}.bak

sed 's/#\s*font\.family\s*:\s*sans-serif/font.family : IPAexGothic/ig' ${FILENAME}.bak >${FILENAME}
rm ${FILENAME}.bak
