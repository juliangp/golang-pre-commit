#!/bin/bash

# This will try to verify the copyrights for the given file extension.

FILE_EXT=$1
shift

FILES=

while [[ $# -gt 0 ]]; do
  FILES="$1 ${FILES}"
  shift
  continue
done

if [[ "${FILE_EXT}" == "" ]]; then
  echo "No file extension found"
  exit 1
fi

# git status -s --porcelain | awk '{ $1=""; print substr($0,2) }'
# $(git ls-tree -r --name-only HEAD)
if [[ "${FILES}" == "" ]]; then
  FILES=$(git status -s --porcelain | awk '{ $1=""; print substr($0,2) }')
fi

echo "Checking files ${FILES}"

set -o pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# git fetch --unshallow &> /dev/null

currentYear=$(date +'%Y')

declare -a fileextensions=("${FILE_EXT}") # ("go")

#declare -a ignore=()
#if [ -f .copyrightignore ]; then
#  IFS=$'\n' read -d '' -r -a ignore < .copyrightignore
#fi

# echo "Ignored files: "
# for e in "${ignore[@]}"; do echo "    - $e"; done

function shouldCheck() {
  local filename=$(basename "$1")
  local fileExtension="${filename##*.}"
  # for e in "${ignore[@]}"; do [[ "$1" =~ $e && "$e" != "" ]] && return 1; done
  for e in "${fileextensions[@]}"; do [[ "$e" == "$fileExtension" ]] && return 0; done
  return 1
}

# just check the files that are modified
for filename in ${FILES}; do
  # echo -e "Checking file $filename"
  shouldCheck "$filename"
  if [[ $? -eq 0 ]]; then
    # we use the current year as the commit date because we are committing now
    # commitDate=$(git log -1 --format="%cd" --date=short -- $filename)
    commitDate=$(date +%Y-%m-%d)
    commitYear=${commitDate%%-*}
    # echo "Commit year: ${commitYear}"

    copyrightYear=$(cat $filename | grep -m1 "Copyright IBM" | sed -En "s/.*Copyright IBM Corp\. ([0-9]+, ){0,1}([0-9]+)\. All Rights Reserved..*$/\2/p")
    copyrightYearCreate=$(cat $filename | grep -m1 "Copyright IBM" | sed -En "s/.*Copyright IBM Corp\. (([0-9]+), ){0,1}([0-9]+)\. All Rights Reserved..*$/\2/p")
    # echo "Copyright year: ${copyrightYear}"

    # if on Travis then get the last committed date from git
    #if [[ -z "$TRAVIS" ]]; then
      creationDate=$(git log --follow --format="%cd" --date=short -- $filename | tail -1)
      if [[ "$creationDate" == "" ]]; then
        echo -e "${RED}Failed to find creation date for: ${filename}${NC}" >&2
      else
        echo "Found creation date ${creationDate} for ${filename}"
      fi
      creationYear=${creationDate%%-*}
    #fi

    newCopyrightDates=$currentYear
    if [[ "$commitYear" != "$creationYear" ]]; then
      newCopyrightDates="$creationYear, $currentYear"
    fi

    if [[ "$commitYear" != "$creationYear" ]]; then
      if [[ "$copyrightYearCreate" != "$creationYear" || "$copyrightYear" != "$commitYear" ]]; then
        if [ -z "${copyrightYear}" ]; then
          echo "Copyright missing from $filename"
        else
          # do this so that we get a date for copyrightYearCreate because in the case of a single year in the copyright then this is not set
          if [[ "${copyrightYearCreate}" == "" ]]; then
            copyrightYearCreate="${copyrightYear}"
          fi
          echo -e "${RED}Copyright needs to be updated for: ${filename}${NC}" >&2
          echo "Committed: ${commitDate} and written as ${copyrightYear}. Created: ${creationDate} and written as ${copyrightYearCreate}"
        fi
        fail=true
      fi
    else
      if [[ "$commitYear" != "$copyrightYear" || "$copyrightYearCreate" ]]; then
        echo -e "${RED}Copyright needs to be updated for: ${filename}${NC}" >&2
        echo "Committed: ${commitDate} and written as ${copyrightYear}."
        if [[ ! -z "$creationDate" ]]; then
          if [[ ! -z "$copyrightYearCreate" ]]; then
            echo "Created: ${creationDate} and written as ${copyrightYearCreate}"
          else
            echo "Created: ${creationDate} and missing from file"
          fi
        fi
        fail=true
      fi
    fi
  fi
done

if [[ "$fail" ]]; then
  # echo -e "\n${RED}Correct copyrights with '--fix' parameter${NC}"
  echo -e "\n${RED}Correct copyrights${NC}"
  exit 1
else
  echo -e "${GREEN}Copyright up to date :)${NC}"
fi
