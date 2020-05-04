#!/usr/bin/env bash

git ls-files | entr go run main.go -contentdir=content -outdir=public -templatedir=.
