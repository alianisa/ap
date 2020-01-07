#!/bin/zsh

set -e

rm -fr build
mkdir -p build/Output/AloSDK
mkdir -p build/Output/ActorCore
mkdir -p build/Output/Resources

rsync -avm --include='*.swift' -f 'hide,! */' AloSDK/Sources/ build/Output/AloSDK
rsync -avm --include='*.m' -f 'hide,! */' AloSDK/Sources/ build/Output/AloSDK
rsync -avm --include='*.h' -f 'hide,! */' AloSDK/Sources/ build/Output/AloSDK

rsync -avm --include='*.*' -f 'hide,! */' AloSDK/Resources/ build/Output/Resources

export PROJECT_DIR=`pwd`
export CONFIGURATION_TEMP_DIR=`pwd`/build/Output/
export PODS_ROOT=`pwd`/Pods

cd AloSDK/Sources/ActorCore
make translate
cd ../../..

cd build/Output/j2objc/
python "${PROJECT_DIR}/preprocess.py"
cd ../../..

rsync -avm --include='*.m' -f 'hide,! */' build/Output/j2objc/Public/ build/Output/ActorCore
rsync -avm --include='*.h' -f 'hide,! */' build/Output/j2objc/Public/ build/Output/ActorCore
