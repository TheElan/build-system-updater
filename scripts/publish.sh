#!/usr/bin/env bash
set -eu

function main() {
  repository_url=$(git remote get-url origin)
  repository_name="$(basename "$repository_url" .git)"
  
  echo "--> Publishing changes for $repository_name"
  changes=$(git status --short)
  if [[ ! "$changes" ]]; then
      echo "<-- Skipping publishing, nothing changed"
      exit 0
  fi 
  git add .
  git commit --message "[ci skip] upgraded build system"
  git push
  
  echo "<-- Published changes successfully"
}

# shellcheck disable=SC2068
main $@
