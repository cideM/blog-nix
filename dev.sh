#!/usr/bin/env bash

# Build project
go run main.go -contentdir=content -outdir=public -templatedir=.
cp styles.css public
echo "Done building"
miniserve public
