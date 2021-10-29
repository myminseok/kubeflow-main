#!/bin/bash

source no-internet-env.sh

set -eo pipefail

EXCLUDE_IMAGE_CONTEXTS=("value" "#" "Look" "for" "specific" "tags" "for" "each" "image" \
	"istio" \
	"tritonserver" \
       	"seldonio/mlserver" \
	"ml-pipeline/frontend" \
	"ml-pipeline/visualization-server" \
	"nvidia/tritonserver" \
	"google-containers/busybox")

SOURCE_DEPLOY_YML="../kubeflow-all-in-one.yml"
OUTPUT_DOWNLOAD_SCRIPT="download-images.sh"
OUTPUT_UPLOAD_SCRIPT="upload-images.sh"
TKG_CUSTOM_IMAGE_REPOSITORY=${TKG_CUSTOM_IMAGE_REPOSITORY:-''}
TKG_IMAGES_DOWNLOAD_FOLDER=${TKG_IMAGES_DOWNLOAD_FOLDER:-''}

GENERATED_DEPLOY_FOLDER="../generated-deploy"
EXTRACTED_IMAGE_REPO_FILE="extracted-image-repo-list"

if [ -z "$TKG_CUSTOM_IMAGE_REPOSITORY" ]; then
  echo "TKG_CUSTOM_IMAGE_REPOSITORY variable is required but is not defined" >&2
  exit 1
fi
if [ -z "$TKG_IMAGES_DOWNLOAD_FOLDER" ]; then
  echo "TKG_IMAGES_DOWNLOAD_FOLDER variable is required but is not defined" >&2
  exit 1
fi
mkdir -p $TKG_IMAGES_DOWNLOAD_FOLDER


if [ ! -f "$SOURCE_DEPLOY_YML" ]; then
    echo "- [WARN] no file exists $SOURCE_DEPLOY_YML"
    exit 1
fi

if [ -n "$TKG_CUSTOM_IMAGE_REPOSITORY_CA_CERTIFICATE" ]; then
  echo $TKG_CUSTOM_IMAGE_REPOSITORY_CA_CERTIFICATE > /tmp/cacrtbase64
  base64 -d /tmp/cacrtbase64 > ./cacrtbase64d.crt
  echo "generated ./cacrtbase64d.crt"
fi

## kubeflow uses docker image with various format, different style. 
## to include as much images list as possible, extract container image repo list from kubeflow deployment scripts.
## this list will be used to generate download and upload images script.
extract_all_image_repo_domain_list(){
  echo "extracting image repo list from deployment scripts ..."
  TMP_FILE="/tmp/${EXTRACTED_IMAGE_REPO_FILE}.tmp"
  echo ""> $TMP_FILE
  echo "" > $EXTRACTED_IMAGE_REPO_FILE
  set +e
  source_files=$(ls -al $GENERATED_DEPLOY_FOLDER | grep "yml" | awk '{print $9}')
  for source_file in ${source_files}; do
    #echo "$source_file"
    grep -e '[a-zA-Z0-9]*\.[a-zA-Z]*\/' "$GENERATED_DEPLOY_FOLDER/$source_file" | grep "image" | grep -v "http" | grep -v "{{" | sed 's/"//g' | awk -F'image:' '{print $2}' | sed 's/http:\/\///;s|\/.*||' | sed 's/ //g' >> $TMP_FILE
  done
  sort $TMP_FILE | uniq  > $EXTRACTED_IMAGE_REPO_FILE
  while IFS= read -r image_repo_domain; do
    echo "    $image_repo_domain"
  done < $EXTRACTED_IMAGE_REPO_FILE
  echo "  generated $EXTRACTED_IMAGE_REPO_FILE"
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
  while IFS= read -r image_repo_domain; do
    if [ -z "${image_repo_domain}" ]; then
      continue
    fi
    echo "generating $COMMAND for ${image_repo_domain} ..."
    ## abc.com/a:v1
    actualImageList=$( grep -r "$image_repo_domain" $SOURCE_DEPLOY_YML |  awk -F"$image_repo_domain" '{print $2}' |sed 's/[",()]//g' | sed 's/^\///g' | awk -F'\' '{print $1}' )
    for actualImageTmp in ${actualImageList}; do
      actualImageAdjusted=$(adjust_image_url "$image_repo_domain/$actualImageTmp")
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
  done < $EXTRACTED_IMAGE_REPO_FILE

  echo "#!/bin/bash" > $OUTPUT_FILE
  echo "export TKG_IMAGES_DOWNLOAD_FOLDER=$TKG_IMAGES_DOWNLOAD_FOLDER" >> $OUTPUT_FILE
  echo "source ./common-lib.sh" >> $OUTPUT_FILE
  echo "cp ./cacrtbase64d.crt /tmp/cacrtbase64d.crt" >> $OUTPUT_FILE
  sort $OUTPUT_TMP | uniq >> $OUTPUT_FILE
  chmod +x $OUTPUT_FILE
  echo "generated $OUTPUT_FILE"
}


extract_all_image_repo_domain_list

generate_script "download_image" $OUTPUT_DOWNLOAD_SCRIPT
generate_script "upload_image"  $OUTPUT_UPLOAD_SCRIPT
