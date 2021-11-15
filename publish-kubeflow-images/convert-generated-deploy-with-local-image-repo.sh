#!/bin/bash

set -e
source no-internet-env.sh

## required: define source file folder to work
SOURCE_DEPLOY_FOLDER="${SOURCE_DEPLOY_FOLDER:-''}"
EXTRACTED_IMAGE_REPO_FILE="${EXTRACTED_IMAGE_REPO_FILE:-''}"
CONVERTED_FOLDER="../converted-deploy"

## code begins ------------------------------------------------------
if [ -z "$SOURCE_DEPLOY_FOLDER" ]; then
  echo "SOURCE_DEPLOY_FOLDER variable is required but is not defined" >&2
  exit 1
fi


mkdir -p $CONVERTED_FOLDER
source_files=$(ls -al $SOURCE_DEPLOY_FOLDER | grep "yml" | awk '{print $9}')
for source_file in ${source_files}; do
  filename=$(echo $source_file | cut -d'/' -f2)
  echo "converting ...  $SOURCE_DEPLOY_FOLDER/$filename"
  cp $SOURCE_DEPLOY_FOLDER/$filename  $CONVERTED_FOLDER/$filename
  ## replace all double quote domain :
  ##  "image": "docker.io/a/b:v1"  ---->  image: local-domain/a/b:v1 
  sed -i 's/ ["]*image["]*: [a-z0-9\-\."]*\// image: infra-harbor.lab.pcfdemo.net\/kubeflow\//g'  $CONVERTED_FOLDER/$filename
  ## image: docker.io/a/b:v1 ==> image: infra-harbor.lab.pcfdemo.net/a/b:v1
  ## replace with exracted domain name 
  while IFS= read -r image_repo_domain; do
    if [ -z "${image_repo_domain}" ]; then
      continue
    fi
    echo "   converting domain ${image_repo_domain} to local domain..."
    command="sed -i 's/image: ${image_repo_domain}/image: infra-harbor.lab.pcfdemo.net\/kubeflow/g' $CONVERTED_FOLDER/$filename"
    eval $command
  done < $EXTRACTED_IMAGE_REPO_FILE

  echo "    completed  $CONVERTED_FOLDER/$filename"
done
echo "review unchanged"
#grep -r -e '[a-zA-Z0-9]*\.[a-zA-Z]*\/' "$CONVERTED_FOLDER" | grep -v "http" | grep -v "{{" | grep -v "infra-harbor"
grep -r " image: " $CONVERTED_FOLDER | grep -v "{{" | grep -v "infra-harbor"
grep -r ' "image": ' $CONVERTED_FOLDER | grep -v "{{"| grep -v "infra-harbor"
