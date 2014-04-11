make-git-release
================

Bash script to assist in the updating of changed files between two respective points in a Git repo.

Authored by Lucas Kacher (<promiseofcake@gmail.com>)

### Usage

Script can be used between any two `hashes`, `tags`, or `branches`

`./makegitrelease.sh <PREV> <NEW>`

Output will create a `../release` folder containing a subfolder named as the `NEW` value.

Originally used to create releases documenting changed files between `feature` branches
and the `master` branch.
