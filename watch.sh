#!/usr/bin/env bash

# Watch project and rebuild
git ls-files | entr -c ./dev.sh
