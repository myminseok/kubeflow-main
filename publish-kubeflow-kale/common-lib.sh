#!/bin/bash

set -e
DOWNLOAD_TMP="/tmp/"

get_download_path(){
  component="$1"
  echo "$DOWNLOAD_PATH/$component"
}

get_download_tmp_path(){
  component="$1"
  echo "$DOWNLOAD_TMP/$component"
}

## param: folder name
prepare_dir(){
  component="$1"
  download_tmp_folder=$(get_download_tmp_path $component)
  echo "==================================================="
  echo "downloading $component $download_tmp_folder"
  mkdir -p $DOWNLOAD_PATH

  rm -rf $download_tmp_folder
  mkdir -p $download_tmp_folder
  chmod 777 $download_tmp_folder
}

move_download(){
  component="$1"
  download_tmp_folder=$(get_download_tmp_path $component)
  download_folder=$(get_download_path $component)
  echo "==================================================="
  echo "moving $component $download_folder"
  rm -rf $download_folder
  mv $download_tmp_folder $download_folder 
}

pip3_install_gz(){
  set -e
  component=$1
  download_tmp_path=$(get_download_tmp_path $component)
  file_list=$(find $download_tmp_path -name "*.gz")
  for file in ${file_list}; do
    msg "Installing $file"
    tar_file=$1
    untar_folder=$( basename $tar_file | awk -F".tar.gz" '{print "/tmp/"$1}')
    tar xf $tar_file -C /tmp
    cd $untar_folder
    python3 setup.py install
    rm -rf /tmp/$untar_folder
  done
}

