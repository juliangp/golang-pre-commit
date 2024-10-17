# golang-pre-commit

## Usage

This repository contains a [`pre-commit`](https://pre-commit.com/#hooks-files) hook that will check copyrights in source files.
In addition some standard `golang` commands (such as `gofmt`) can also be used.

The following ids can be used:

   1. `check-go-copyright` - this will check the copyright of go files.
   1. `check-scala-copyright` - this will check the copyright of Scala files.
   1. `check-python-copyright` - this will check the copyright of Python files.

The copyright script will check the files that are passed in by `pre-commit`,
if the file list is empty then it will check locally modified files, which it does as shown below:

   ```shell
   git status -s --porcelain
   ```

## Copyright header

For this script to work there must be a line in the file that matches this regular expression:

   ```shell
   .*Copyright IBM Corp\. [0-9]+, {0,1}[0-9]+\. All Rights Reserved..*$
   ```

The following are some examples:

   ```go
   // Copyright IBM Corp. 2022. All Rights Reserved.
   ```

   ```go
   // Copyright IBM Corp. 2022, 2023. All Rights Reserved.
   ```

## golang ids

   1. `go-fmt` - this will run `go fmt` on all the go files.

## golines

This will use [golines](https://github.com/segmentio/golines) to format files for maximum line length.

In the `args` section you can specifiy options such as `--max-len=120 --tab-len=2`.

Note that the hook will try to install `golines` as for now the golang support
in `pre-commit` does not support [additional_dependencies](https://pre-commit.com/#golang).
