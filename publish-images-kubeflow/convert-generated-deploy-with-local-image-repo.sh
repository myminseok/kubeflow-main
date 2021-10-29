#!/bin/bash

set -e
SOURCE_FOLDER="../generated-deploy"
CONVERTED_FOLDER="../converted-deploy"
EXTRACTED_IMAGE_REPO_FILE="extracted-image-repo-list-from-deploy"

mkdir -p $CONVERTED_FOLDER
source_files=$(ls -al $SOURCE_FOLDER | grep "yml" | awk '{print $9}')
for source_file in ${source_files}; do
  filename=$(echo $source_file | cut -d'/' -f2)
  echo "converting ...  $CONVERTED_FOLDER/$filename"
  cp $SOURCE_FOLDER/$filename $CONVERTED_FOLDER/$filename
  ## replace the first domain name 
  ## image: docker.io/a/b:v1 ==> image: infra-harbor.lab.pcfdemo.net/a/b:v1
  sed -i 's/ ["]*image["]*: [a-z0-9\-\."]*\// image: infra-harbor.lab.pcfdemo.net\/kubeflow\//g'  $CONVERTED_FOLDER/$filename


  ## replace with exracted domain name 
  while IFS= read -r image_repo_domain; do
    if [ -z "${image_repo_domain}" ]; then
      continue
    fi
    echo "   converting for ${image_repo_domain} ..."
    command="sed -i 's/$image_repo_domain/infra-harbor.lab.pcfdemo.net\/kubeflow/g' $CONVERTED_FOLDER/$filename"
    eval $command
  done < $EXTRACTED_IMAGE_REPO_FILE

  echo "    completed  $CONVERTED_FOLDER/$filename"
done
echo "review unchanged"
#grep -r -e '[a-zA-Z0-9]*\.[a-zA-Z]*\/' "$CONVERTED_FOLDER" | grep -v "http" | grep -v "{{" | grep -v "infra-harbor"
grep -r " image: " $CONVERTED_FOLDER | grep -v "{{" | grep -v "infra-harbor"
grep -r ' "image": ' $CONVERTED_FOLDER | grep -v "{{"| grep -v "infra-harbor"
