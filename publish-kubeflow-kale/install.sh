#!/bin/bash
set -e

DOWNLOAD_PATH="/data/kubeflow-kale-bin/kubeflow-kale"
msg(){
  echo ""
  echo "$1 ================================================"
}

pip3_install_gz(){
  set -e
  tar_file=$1
  untar_folder=$( basename $tar_file | awk -F".tar.gz" '{print "/tmp/"$1}')
  tar xf $tar_file -C /tmp
  cd $untar_folder
  python3 setup.py install
  rm -rf /tmp/$untar_folder
}


file_list=$(find $DOWNLOAD_PATH -name "*.gz")
for file in ${file_list}; do
  msg "Installing $file"
  pip3_install_gz $file
done
