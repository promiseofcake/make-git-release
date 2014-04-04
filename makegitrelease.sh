#!/bin/bash
# @author Lucas Kacher <lucaskacher@gmail.com>
# Git Release Export Script

# Creates a diff between any two given Hashes, Tags or Branches, 
# and exports the changeset to a directory for easy upload.

# parameters
# date
DATENOW=$(date +"%Y-%m-%d %H:%M:%S");
# older history reference
PREV=$1
# new history reference
NEW=$2
# replace slashes with dashes in git reference
DIR=${NEW//\//-};
LOG="../release/log-${DIR}.txt"

# check that both parameters exist
if [ -z "$PREV" ] || [ -z "$NEW" ]; then
	echo "Usage: makegitrelease.sh <PREV> <NEW>";
	exit 2
fi

# check that first parameter is a valid git reference
git log -n 1 ${PREV} > /dev/null 2>&1;
if [ "$?" -ne 0 ]; then
	echo "${PREV} is not a valid HASH, TAG, or BRANCH, please try again."
	exit 2;
fi

# check that second parameter is a valid git reference
git log -n 1 ${NEW} > /dev/null 2>&1;
if [ "$?" -ne 0 ]; then
	echo "${NEW} is not a valid HASH, TAG, or BRANCH, please try again."
	exit 2;
fi

# get the list of files from the diff and copy them
# to a release directory
 
# remove any previous release directories that match the new commit hash
if [ -d "../release/${DIR}" ]; then
	echo "Removing previous directory: ${DIR}";
	rm -rf "../release/${DIR}/";
fi

# get list of modified files, and copy them over
git diff ${PREV} ${NEW} --name-only --diff-filter=ACMRT | \
while read files; \
  do mkdir -p "../release/${DIR}/$(dirname $files)"; \
  cp -f $files ../release/${DIR}/$(dirname $files); \
done;

# if previous command did not exit with success
if [ "$?" -ne 0 ]; then
	echo "Error in Git Release for ${NEW}";
	echo "There was an error creating the git release between ${PREV} and ${NEW}, please try again";
	exit 1;
fi

# remove any log files that match the new commit hash
rm ${LOG} > /dev/null 2>&1;

# re-create log file
touch ${LOG};
echo "${DATENOW} Git Release for ${NEW}" > ${LOG};

# add in files to delete
echo "" >> ${LOG};
echo "Files to Delete: " >> ${LOG};
git diff ${PREV} ${NEW} --name-only --diff-filter=D | \
while read files; \
  do echo "D $files" >> ${LOG}; \
done;

# add to the log file the commits included in this release
echo >> ${LOG};
echo "Commits Included in Release:" >> ${LOG};
echo 'git log --merges --pretty=format:"%h %s"' ${PREV}'...'${NEW}
git log --merges --pretty=format:"%h %s" ${PREV}...${NEW} >> ${LOG}

# final notes, exit 0
echo "Git Release Created for ${NEW}";
echo "Release prepared and copied to ../release/${DIR}. All additions and modifications between ${PREV} and ${NEW} have been noted. Please manually check for deletions.";

exit 0;

