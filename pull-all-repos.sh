#!/bin/bash
# must be chmod +x

# repos for deploy
REPOS=(
    laravel-ddd-skeleton
#     frontend.panel
)

# shellcheck disable=SC2068
for repo in ${REPOS[@]}; do
    git -C ../"$repo" pull || git clone git@github.pro:dostoevksiy-spb/"$repo".git ../"$repo"
done
