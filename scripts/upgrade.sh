#!/bin/bash
set -eu

function main() {
  repository_url=$(git remote get-url origin)
  repository_name="$(basename "$repository_url" .git)"
  
  echo "--> Updating build system of $repository_name"
  
  chmod +x gradlew
  ./gradlew updateBuildScript
  ./gradlew clean build test
  
  echo "<-- Build system updated successfully"
}

# shellcheck disable=SC2068
main $@
