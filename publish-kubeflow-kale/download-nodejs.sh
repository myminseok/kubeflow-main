#!/bin/bash

set -e
CURRENT_DIR=`dirname $(readlink -f ${BASH_SOURCE})`
DOWNLOAD_PATH="/data/kubeflow-kale-bin"
DOWNLOAD_TMP="/tmp/"

source ./common-lib.sh


prepare_dir nodejs
cd $(get_download_tmp_path nodejs)
apt download nodejs
apt download $( apt-rdepends nodejs| grep -v "^ "| grep -v "debconf-2.0")
move_download nodejs


echo "complated ==========================================="
