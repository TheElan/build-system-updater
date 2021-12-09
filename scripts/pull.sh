#!/bin/bash
set -eu

function main() {
  repository_url=$1
  repository_name=$2
  
  echo "--> Pulling $repository_name"
  if [[ -d "$repository_name" ]]; then
    pushd "$repository_name"
      git fetch origin master
      git reset origin/master
      git clean -df
    popd
  else
    git clone --depth 2 "$repository_url"
  fi 
  echo "<-- Pulled successfully"
}

# shellcheck disable=SC2068
main $@
