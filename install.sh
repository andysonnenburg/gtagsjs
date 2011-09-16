#!/bin/sh

set -o errexit
set -o nounset

cd gtags
cabal install --enable-shared
cd ..

cd gtagsjs-command
cabal install
cd ..

cd gtagsjs-function
cabal install
cd ..
