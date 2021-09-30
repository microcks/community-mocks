#!/bin/sh -x
set -e

apiVersion_file=$1
apiVersion_dir=$(dirname "$apiVersion_file")

# Validate the API version file according the schema.
ajv validate -s schemas/APIVersion-v1alpha1-schema.json -d $apiVersion_file -c ajv-formats

# Ensure API version contracts exists and are reachable.
for contract in $(yq e '.spec.contracts' $apiVersion_file -j | jq -c '.[]'); do
  contractUrl=$(echo "$contract" | jq -r '.url')
  echo "Testing if $contractUrl URL is reachable"
  contractCode=$(curl -L "$contractUrl" -s -o /dev/null -w "%{http_code}")
  test "$contractCode" = "200"
done
