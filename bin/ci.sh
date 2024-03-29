#!/bin/bash

set -x

echo "Remove .robloxrc from dev dependencies"
find Packages/Dev -name "*.robloxrc" | xargs rm -f
find Packages/_Index -name "*.robloxrc" | xargs rm -f

echo "Run static analysis"
selene src
robloxdev-cli analyze analyze.project.json
stylua -c src

echo "Run tests"
robloxdev-cli run --load.place tests.project.json --run bin/spec.lua \
    --lua.globals=__DEV__=true \
    --fastFlags.allOnLuau --fastFlags.overrides EnableLoadModule=true \
    --fs.read=$PWD --load.asRobloxScript --headlessRenderer 1 --virtualInput 1

echo "Run tests with mock scheduler"
robloxdev-cli run --load.place tests.project.json --run bin/spec.lua \
    --lua.globals=__DEV__=true --lua.globals=__ROACT_17_MOCK_SCHEDULER__=true \
    --fastFlags.allOnLuau --fastFlags.overrides EnableLoadModule=true \
    --fs.read=$PWD --load.asRobloxScript --headlessRenderer 1 --virtualInput 1
