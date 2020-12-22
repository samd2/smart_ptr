#!/bin/bash

set -ex
export TRAVIS_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=$DRONE_BRANCH
export TRAVIS_OS_NAME=${DRONE_JOB_OS_NAME:-linux}
export VCS_COMMIT_ID=$DRONE_COMMIT
export GIT_COMMIT=$DRONE_COMMIT
export DRONE_CURRENT_BUILD_DIR=$(pwd)
export PATH=~/.local/bin:/usr/local/bin:$PATH

echo '==================================> BEFORE_INSTALL'

. .drone/before-install.sh

echo '==================================> INSTALL'

BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
cd ..
git clone -b $BOOST_BRANCH https://github.com/boostorg/boost.git boost-root
cd boost-root
git submodule init libs/align
git submodule init libs/assert
git submodule init libs/atomic
git submodule init libs/config
git submodule init libs/container_hash
git submodule init libs/core
git submodule init libs/move
git submodule init libs/predef
git submodule init libs/static_assert
git submodule init libs/throw_exception
git submodule init libs/type_traits
git submodule init libs/detail
git submodule init libs/integer
git submodule init tools/build
git submodule init libs/headers
git submodule init tools/boost_install
git submodule init tools/cmake
git submodule init libs/preprocessor
git submodule init libs/bind
git submodule update
cp -r $TRAVIS_BUILD_DIR/* libs/smart_ptr
./bootstrap.sh
./b2 headers

echo '==================================> BEFORE_SCRIPT'

. $DRONE_CURRENT_BUILD_DIR/.drone/before-script.sh

echo '==================================> SCRIPT'

echo "using $TOOLSET : : $COMPILER ;" > ~/user-config.jam
./b2 -j3 libs/smart_ptr/test toolset=$TOOLSET cxxstd=$CXXSTD variant=debug,release ${UBSAN:+cxxflags=-fsanitize=undefined cxxflags=-fno-sanitize-recover=undefined linkflags=-fsanitize=undefined debug-symbols=on} ${LINKFLAGS:+linkflags=$LINKFLAGS}

echo '==================================> AFTER_SUCCESS'

. $DRONE_CURRENT_BUILD_DIR/.drone/after-success.sh
