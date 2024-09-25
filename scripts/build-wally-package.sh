#!/bin/sh

set -e

rm -rf temp

mkdir -p temp

cp -r src temp/src

./scripts/remove-tests.sh temp

wally_package=build/wally
rm -rf $wally_package

echo Process package

mkdir -p $wally_package
cp LICENSE $wally_package/LICENSE

node ./scripts/npm-to-wally.js package.json $wally_package/wally.toml $wally_package/default.project.json temp/wally-package.project.json

cp .darklua-wally.json temp
cp -r node_modules/.luau-aliases/* temp

rojo sourcemap temp/wally-package.project.json --output temp/sourcemap.json

darklua process --config temp/.darklua-wally.json temp/src $wally_package/src

wally package --project-path $wally_package --list
