#!/bin/bash

set -e
source no-internet-env.sh

## required: define source file folder to work
CONVERTED_FOLDER="../converted-deploy"

## code begins ------------------------------------------------------
if [ -z "$CONVERTED_FOLDER" ]; then
  echo "SOURCE_DEPLOY_FOLDER variable is required but is not defined" >&2
  exit 1
fi

echo "starting.."
source_files=$(ls -al $CONVERTED_FOLDER | grep "yml" | awk '{print $9}')
for source_file in ${source_files}; do
  filename=$(echo $source_file | cut -d'/' -f2)
  echo "converting ...  $CONVERTED_FOLDER/$filename"
  sed -i 's/ ["]*image["]*: "proxyv2"/ image: platform-harbor.mvp.bsl.local\/kubeflow\/istio\/proxyv2:1.9.6/g'  $CONVERTED_FOLDER/$filename
  sed -i 's/ image: mysql/ image: platform-harbor.mvp.bsl.local\/kubeflow\/ml-pipeline\/mysql/g'  $CONVERTED_FOLDER/$filename
  sed -i 's/ image: python/ image: platform-harbor.mvp.bsl.local\/kubeflow\/python/g'  $CONVERTED_FOLDER/$filename
  sed -i 's/gcr.io\//platform-harbor.mvp.bsl.local\/kubeflow\//g'  $CONVERTED_FOLDER/$filename
done
echo "review unchanged"
#grep -r -e '[a-zA-Z0-9]*\.[a-zA-Z]*\/' "$CONVERTED_FOLDER" | grep -v "http" | grep -v "{{" | grep -v "platform-harbor"
grep -r " image: " $CONVERTED_FOLDER | grep -v "{{" | grep -v "platform-harbor"
grep -r ' "image": ' $CONVERTED_FOLDER | grep -v "{{"| grep -v "platform-harbor"
