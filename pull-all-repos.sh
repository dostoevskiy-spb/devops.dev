#!/bin/bash
# must be chmod +x

if [[ -d ../backend.api && -d ../backend.api/.git ]]
then
  git -C ../backend.api pull
else
  git clone git@github.com:dostoevskiy-spb/laravel-ddd-skeleton.git ../backend.api
fi
