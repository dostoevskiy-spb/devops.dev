#!/bin/bash
# must be chmod +x

# repos for deploy
REPOS=(
    devops.dev
    backend.api
#     frontend.panel
)

for repo in ${REPOS[@]}; do
    git -C ../$repo pull || git clone git@github.pro:dostoevksiy-spb/$repo.git ../$repo
done