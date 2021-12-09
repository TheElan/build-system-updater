#!/bin/bash
set -eu

echo "Ensuring repositories are present and up to date"

script_directory="$(dirname "$(readlink --canonicalize "${0}")")"
repositories_directory="$script_directory/../repositories"
repositories_list_file="$script_directory/../repositories.list"
repositories="$(cat $repositories_list_file)"

function clone() {
  repository_url=$1
  repository_name=$2    

  git clone \
    --depth 1 \
    $repository_url
}

function update() {
  repository_name=$1
  
  pushd $repository_name
    git fetch origin master
    git reset origin/master
  popd
}

mkdir --parents "$repositories_directory"
pushd "$repositories_directory"
  for repository_url in $repositories
  do
    repository_name=$(basename $repository_url .git)
    clone $repository_url $repository_name
    update $repository_name
  done
popd

echo "Finished cloning and updating repositories"
