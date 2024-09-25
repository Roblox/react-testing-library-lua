#!/bin/sh

set -e

./scripts/build-roblox-model.sh .darklua.json react-testing-library.rbxm
./scripts/build-roblox-model.sh .darklua-dev.json debug/react-testing-library.rbxm

./scripts/build-wally-package.sh
