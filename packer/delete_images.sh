#!/bin/bash

# get environment variables from the metadata
get_var() {
  local name="$1"

  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}

export BUCKET_NAME=$(get_var "bucketName")
export RAILS_ENV="$(get_var "railsEnv")"

# pull the list of images from the GCP bucket
gsutil cp gs://${BUCKET_NAME}/state/${RAILS_ENV}/images/image_tags.txt .
#count the number of images(lines) in the file
img_num=$(wc -l < image_tags.txt)
# Check if the number of images is more than 10 to allow deleting the oldest ones
# and leave the newest 10 to be on the safe side
if [[ $img_num -gt 10 ]]; then
  num_img_to_del=$(( img_num - 10 ))
  # create a new file with the image names to be deleted
  cat image_tags.txt | head -n $num_img_to_del > images_to_delete.txt
  #loop through the new file picking the names and deleting them
  for image_name in $(cat images_to_delete.txt); do
    gcloud compute images delete $image_name --quiet
    # Delete the image tags of the deleted images from the bucket file
    sed -i "/${image_name}/d" ./image_tags.txt
  done
  gsutil cp /home/vof/image_tags.txt gs://${BUCKET_NAME}/state/${RAILS_ENV}/images/image_tags.txt
fi

#delete the txt files
rm image_tag.txt
rm images_to_delete.txt