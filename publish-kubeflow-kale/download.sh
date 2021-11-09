#!/bin/bash

set -e
CURRENT_DIR=`dirname $(readlink -f ${BASH_SOURCE})`
DOWNLOAD_PATH="/data/kubeflow-kale-bin"
DOWNLOAD_TMP="/tmp/"

source ./common-lib.sh


prepare_dir kubeflow-kale
cd $(get_download_tmp_path kubeflow-kale)
pip3 download "kubeflow-kale"
pip3 install *
move_download kubeflow-kale

prepare_dir jupyterlab
cd $(get_download_tmp_path jupyterlab)
pip3 download "jupyterlab>=2.0.0,<3.0.0"
pip3 download 'google-api-core<2dev,>=1.21.0'
pip3 install *
pip3_install_gz jupyterlab
move_download jupyterlab


echo "complated ==========================================="
