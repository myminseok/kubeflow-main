#!/bin/bash

source no-internet-env.sh

set -eo pipefail

## required: define source file folder to work
SOURCE_DEPLOY_FOLDER="${SOURCE_DEPLOY_FOLDER:-''}"

## optional:
## define image url to skip from download, upload script.
## - <image-repository-context>
## - <image-registry-domain>/<image-registry-context>
#EXCLUDE_IMAGE_CONTEXTS=("value" "#" "Look" "for" "specific" "tags" "for" "each" "image") 
EXCLUDE_IMAGE_CONTEXTS="${EXCLUDE_IMAGE_CONTEXTS:-''}"

## internal variables-------------------------------------------------------
SOURCE_FILES_EXTRACTED="_tmp_source_files"
IMAGE_REPOS_EXTRACTED="_tmp_image_repos"
OUTPUT_DOWNLOAD_SCRIPT="download-images.sh"
OUTPUT_UPLOAD_SCRIPT="upload-images.sh"
TKG_CUSTOM_IMAGE_REPOSITORY=${TKG_CUSTOM_IMAGE_REPOSITORY:-''}
TKG_IMAGES_DOWNLOAD_FOLDER=${TKG_IMAGES_DOWNLOAD_FOLDER:-''}

## code begins ------------------------------------------------------
if [ -z "$SOURCE_DEPLOY_FOLDER" ]; then
  echo "SOURCE_DEPLOY_FOLDER variable is required but is not defined" >&2
  exit 1
fi

if [ -z "$TKG_CUSTOM_IMAGE_REPOSITORY" ]; then
  echo "TKG_CUSTOM_IMAGE_REPOSITORY variable is required but is not defined" >&2
  exit 1
fi
if [ -z "$TKG_IMAGES_DOWNLOAD_FOLDER" ]; then
  echo "TKG_IMAGES_DOWNLOAD_FOLDER variable is required but is not defined" >&2
  exit 1
fi
mkdir -p $TKG_IMAGES_DOWNLOAD_FOLDER


if [ -n "$TKG_CUSTOM_IMAGE_REPOSITORY_CA_CERTIFICATE" ]; then
  echo $TKG_CUSTOM_IMAGE_REPOSITORY_CA_CERTIFICATE > /tmp/cacrtbase64
  base64 -d /tmp/cacrtbase64 > ./cacrtbase64d.crt
  echo "generated ./cacrtbase64d.crt"
fi

extract_source_files(){
  echo "selecting deployment files as source  ..."
  set +e
  ls -al $SOURCE_DEPLOY_FOLDER | grep "yml" | awk '{print $9}' > $SOURCE_FILES_EXTRACTED
  cat $SOURCE_FILES_EXTRACTED
  echo "  generated $SOURCE_FILES_EXTRACTED"
}

## kubeflow uses docker image with various format, different style. 
## to include as much images list as possible, extract container image repo list from kubeflow deployment scripts.
## this list will be used to generate download and upload images script.
extract_all_image_repo_list(){
  echo "extracting image repo list from deployment scripts ..."
  TMP_FILE="/tmp/${IMAGE_REPOS_EXTRACTED}.tmp"
  echo ""> $TMP_FILE
  echo "" > $IMAGE_REPOS_EXTRACTED
  set +e
  while IFS= read -r source_file; do
    grep -e '[a-zA-Z0-9_\-\.]*\/' "$SOURCE_DEPLOY_FOLDER/$source_file" \
	    | grep "image" | grep -v "http" | grep -v "{{" | sed 's/"//g' \
	    | awk -F'image:' '{print $2}' | sed 's/http:\/\///;s|\/.*||' | sed 's/ //g' >> $TMP_FILE
  done < $SOURCE_FILES_EXTRACTED

  sort $TMP_FILE | uniq  > $IMAGE_REPOS_EXTRACTED
  while IFS= read -r image_repo; do
    echo "    $image_repo"
  done < $IMAGE_REPOS_EXTRACTED
  echo "  generated $IMAGE_REPOS_EXTRACTED"
}


## check if imageRepo is in exclude list. exact matching
## param: image context with tag without domain name
is_skip_image_repo_and_tag(){
  actualImageContext=$1
  for excludeContext in "${EXCLUDE_IMAGE_CONTEXTS[@]}"; do
     ##  echo "     '$actualImageContext' -> '$excludeContext' "
     if [ "$excludeContext" = "$actualImageContext"  ]; then  
       echo "true"
       return
     fi
  done
  echo "false"
}

## param: docker image repo url
adjust_image_url(){
  inputRepo=$1
  outputRepo=$inputRepo
  if [[ ! "$inputRepo" =~ "/"  ]]; then  
    outputRepo="docker.io/$outputRepo"
  fi
 # if [[ ! "$inputRepo" =~ ":"  ]]; then  
 #   outputRepo="$outputRepo:latest"
 # fi
  echo "$outputRepo"
}

## param: docker image repo url
generate_output_line(){
  inputRepo=$1
  actualImage=$(adjust_image_url $inputRepo)
  ## imagename  witout tag
  imageContext=$(echo ${actualImage} | cut -d"/" -f2- | cut -d":" -f1 | cut -d"@" -f1 )
  customImage=$TKG_CUSTOM_IMAGE_REPOSITORY/${imageContext} 
  echo "$COMMAND -i $actualImage --to-repo $customImage --registry-ca-cert-path /tmp/cacrtbase64d.crt" 
}



## params: 
## SOURCE_DEPLOY_YML
## COMMAND
## OUTPUT_FILE
generate_script(){
  COMMAND=$1
  OUTPUT_FILE=$2

  OUTPUT_TMP="/tmp/${OUTPUT_FILE}"
  echo "" > $OUTPUT_TMP
  while IFS= read -r image_repo; do
    if [ -z "${image_repo}" ]; then
      continue
    fi
    echo "processing $COMMAND for ${image_repo} ..."
    ## abc.com/a:v1
    echo "grep -r $image_repo $SOURCE_DEPLOY_FOLDER/*.yml |  awk -F\"$image_repo/\" '{print \$2}' |sed 's/[\",()]//g' | sed 's/^\///g' | awk -F'\' '{print \$1}'"
    actualImageList=$(grep -r "$image_repo" $SOURCE_DEPLOY_FOLDER/*.yml |  awk -F"$image_repo/" '{print $2}' |sed 's/[",()]//g' | sed 's/^\///g' | awk -F'\' '{print $1}' )
    for actualImageTmp in ${actualImageList}; do
      actualImageAdjusted=$(adjust_image_url "$image_repo/$actualImageTmp")
      # image repo with tag. no domain
      imageRepoAndTag=$(echo ${actualImageAdjusted} | cut -d"/" -f2- )
      if [ "$(is_skip_image_repo_and_tag $imageRepoAndTag)" = "true" ]; then
	      echo "skipng image context: $actualImageAdjusted"
	      continue
      fi
      echo "  adding    $actualImageAdjusted"
      ## image  repo name without tag
      imageContext=$(echo ${actualImageAdjusted} | cut -d"/" -f2- | cut -d":" -f1 | cut -d"@" -f1 )
      customImage=$TKG_CUSTOM_IMAGE_REPOSITORY/${imageContext} 
      echo "$COMMAND -i $actualImageAdjusted --to-repo $customImage --registry-ca-cert-path /tmp/cacrtbase64d.crt" >> $OUTPUT_TMP
    done
  done < $IMAGE_REPOS_EXTRACTED

  echo "#!/bin/bash" > $OUTPUT_FILE
  echo "export TKG_IMAGES_DOWNLOAD_FOLDER=$TKG_IMAGES_DOWNLOAD_FOLDER" >> $OUTPUT_FILE
  echo "source ./common-lib.sh" >> $OUTPUT_FILE
  echo "cp ./cacrtbase64d.crt /tmp/cacrtbase64d.crt" >> $OUTPUT_FILE
  sort $OUTPUT_TMP | uniq >> $OUTPUT_FILE
  chmod +x $OUTPUT_FILE
  echo "generated $OUTPUT_FILE"
}

extract_source_files
extract_all_image_repo_list

generate_script "download_image" $OUTPUT_DOWNLOAD_SCRIPT
generate_script "upload_image"  $OUTPUT_UPLOAD_SCRIPT
