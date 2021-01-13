#!/bin/sh

set -e # fail fast
set -x # print commands

# copy the resource-gist into the updated-gist directory
git clone resource-gist updated-gist

# add the date to updated-gist/bumpme
cd updated-gist
date > bumpme

# set git user
git config --global user.email "nobody@concourse-ci.org"
git config --global user.name "Concourse"

# commit the change
git add .
git commit -m "Bumped date"
