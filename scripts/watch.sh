#!/usr/bin/env bash

GITROOT=$(git rev-parse --show-toplevel)

# Watch project and rebuild
watchexec --clear --restart "$GITROOT"/scripts/dev.sh
