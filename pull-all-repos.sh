#!/bin/bash
# must be chmod +x

git -C ../backend.api pull || git clone git@github.pro:dostoevksiy-spb/laravel ddd-skeleton.git ../backend.api
