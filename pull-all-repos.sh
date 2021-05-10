#!/bin/bash
# must be chmod +x

declare -A repos
repos["backend.api"]="laravel-ddd-skeleton.git"

# shellcheck disable=SC2034
for repo_dir in "${!repos[@]}"; do
  if [[ -d ../"$repo_dir" && -d ../"$repo_dir"/.git ]]; then
    git -C ../"$repo_dir" pull
  else
    git clone git@github.com:dostoevskiy-spb/${repos[$repo_dir]} ../"$repo_dir"
  fi
done
