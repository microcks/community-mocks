#!/bin/sh -x
set -e

package_file=$1
package_dir=$(dirname "$package_file")

# Validate the package file according the schema.
ajv validate -s schemas/APIPackage-v1alpha1-schema.json -d $package_file -c ajv-formats

# Ensure APIs versions exist.
for api in $(yq e '.spec.apis' $package_file -j | jq -c '.[]'); do
  apiName=$(echo "$api" | jq -r '.name')
  apiVersion=$(echo "$api" | jq -r '.currentVersion')
  apiVersionFile=$package_dir/$apiName/$apiVersion/$apiName.$apiVersion.api.yml
  echo "Testing if $apiVersionFile file exists"
  test -e "$apiVersionFile"
done
