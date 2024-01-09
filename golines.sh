#!/bin/sh

# set -x

# we have to install golines if not already installed
go install github.com/segmentio/golines@latest

exe=$(go env GOPATH)/bin/golines

echo "${exe} --list-files --write-output $@"

LIST_OF_FILES=$(${exe} --list-files --write-output $@)
# print a list of affected files if any
echo "$LIST_OF_FILES"
if [ -n "$LIST_OF_FILES" ];then
    exit 1
fi
