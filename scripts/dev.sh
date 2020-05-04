#!/usr/bin/env bash

GITROOT=$(git rev-parse --show-toplevel)

# Build project
go run main.go -contentdir="$GITROOT"/content -outdir="$GITROOT"/public -templatedir="$GITROOT"/go_templates
cp styles.css public
echo "Done building"
miniserve public
