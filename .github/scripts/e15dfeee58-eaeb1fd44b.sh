#!/bin/bash

set -ex
export TRAVIS_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=${TRAVIS_BRANCH:-$(echo $GITHUB_REF | awk 'BEGIN { FS = "/" } ; { print $3 }')}
export VCS_COMMIT_ID=$GITHUB_SHA
export GIT_COMMIT=$GITHUB_SHA
export REPO_NAME=$(basename $GITHUB_REPOSITORY)
export PATH=~/.local/bin:/usr/local/bin:$PATH

echo '==================================> BEFORE_INSTALL'

. .github/scripts/before-install.sh

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

. $GITHUB_WORKSPACE/.github/scripts/before-script.sh

echo '==================================> SCRIPT'

mkdir __build__ && cd __build__
cmake -DBOOST_ENABLE_CMAKE=1 -DBoost_VERBOSE=1 -DBOOST_INCLUDE_LIBRARIES=smart_ptr -DBUILD_TESTING=ON ..
ctest --output-on-failure -R boost_smart_ptr

echo '==================================> AFTER_SUCCESS'

. $GITHUB_WORKSPACE/.github/scripts/after-success.sh
