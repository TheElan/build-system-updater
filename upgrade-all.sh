#!/usr/bin/env bash
set -eu

main() {
  repository_root="$(dirname "$(readlink --canonicalize "${0}")")"
  
  pull_script="$repository_root/scripts/pull.sh"
  reports_directory="$repository_root/reports"
  failed_pull_list_file="$reports_directory/failed-pulls.list"
  
  upgrade_script="$repository_root/scripts/upgrade.sh"
  failed_upgrade_list_file="$reports_directory/failed-upgrades.list"
  
  publish_script="$repository_root/scripts/publish.sh"
  failed_publish_list_file="$reports_directory/failed-publishes.list"
  
  repositories_directory="/tmp/org-build-system-update/repositories"
  repositories_list_file="$repository_root/repositories.list"
  repositories="$(cat "$repositories_list_file")"

  echo "---> Upgrading all repositories"

  rm --force "$failed_pull_list_file" "$failed_upgrade_list_file" "$failed_publish_list_file"
  mkdir --parents "$repositories_directory" "$reports_directory"
  pushd "$repositories_directory"
  
    pull_each_with "$pull_script" "$repositories" "$failed_pull_list_file"
    if [[ -f "$failed_pull_list_file" ]]; then
     
      echo "<-! Failed to pull:";
      cat "$failed_pull_list_file"
      exit 1
    fi
  
    for_each_repository upgrade_with "$upgrade_script" "$failed_upgrade_list_file"
    if [[ -f "$failed_upgrade_list_file" ]]; then
     
      echo "<-! Failed to upgrade:";
      cat "$failed_upgrade_list_file"
      exit 1
    fi
      
    for_each_repository publish_changes "$publish_script" "$failed_publish_list_file"
    if [[ -f "$failed_publish_list_file" ]]; then
      echo "<-! Failed to publish changes:";
      cat "$failed_publish_list_file"
      exit 1
    fi

  popd

  echo "<--- Upgrade finished successfully"
}

pull_each_with() {
  pull_script=$1
  repositories=$2
  failed_pull_list_file=$3

  set +e
  for repository_url in $repositories
  do
    repository_name_with_extension="${repository_url##*/}"
    repository_name="${repository_name_with_extension%.*}"

    $pull_script "$repository_url" "$repository_name"
    exit_code=$?
    if [[ $exit_code != 0 ]]; then
        echo "$repository_name" >> "$failed_pull_list_file"
        echo "<-! Pulling $repository_name failed"
    fi
  done
  set -e
}

upgrade_with() {
  repository_name=$1
  upgrade_script=$2
  failed_upgrade_list_file=$3

  set +e
  $upgrade_script
  exit_code=$?
  if [[ $exit_code != 0 ]]; then
      echo "$repository_name" >> "$failed_upgrade_list_file"
      echo "<-! Upgrading $repository_name failed"
  fi
  set -e
}

publish_changes() {
  repository_name=$1
  publish_script=$2
  failed_publish_list_file=$3

  set +e
  $publish_script
  exit_code=$?
  if [[ $exit_code != 0 ]]; then
      echo "$repository_name" >> "$failed_publish_list_file"
      echo "<-! Publishing $repository_name failed"
  fi
  set -e
}

for_each_repository() {
    command=$1
    shift

    for repository_url in $repositories
    do
      repository_name_with_extension="${repository_url##*/}"
      repository_name="${repository_name_with_extension%.*}"
      
      pushd "$repository_name"
        # shellcheck disable=SC2068
        $command "$repository_name" $@
      popd
    done
}

# shellcheck disable=SC2068
main $@
