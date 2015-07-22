#!/bin/bash

source /data_dirs.env

mkdir -p /owncloud-data
cd /opt/owncloud
for datadir in "${DATA_DIRS[@]}"; do
  if [ -e $datadir ]
  then
    mv ${datadir} ${datadir}-template
  fi
  ln -s /owncloud-data/${datadir#/*} ${datadir}
done

for dotfile in "${DATA_DOT_FILES[@]}"; do
  if [ -e "$dotfile" ]
  then
     mv ${dotfile} ${dotfile}-template
  fi
  ln -s /owncloud-data/dotfiles/${dotfile#/*} ${dotfile}
done