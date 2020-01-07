set -e

#pod install
#pod update

# rm -fr build
mkdir -p build/Output

xcodebuild \
  -workspace "AloSDK.xcworkspace" \
  -scheme "AloSDK" \
  -derivedDataPath build \
  -arch armv7 -arch armv7s -arch arm64 \
  -sdk iphoneos \
  ONLY_ACTIVE_ARCH=NO \
  -configuration Release \
  -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=4 \
  OTHER_CFLAGS="-fembed-bitcode" \
  build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

xcodebuild \
  -workspace "AloSDK.xcworkspace" \
  -scheme "AloSDK" \
  -derivedDataPath build \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 6' \
  ONLY_ACTIVE_ARCH=NO \
  -configuration Release \
  -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=4 \
  OTHER_CFLAGS="-fembed-bitcode" \
  build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

rm -f build/Output/libalo.so
lipo -create "build/Build/Intermediates.noindex/AloSDK.build/Release-iphoneos/j2objc/Objects/libalo.so" "build/Build/Intermediates.noindex/AloSDK.build/Release-iphonesimulator/j2objc/Objects/libalo.so" -output build/Output/libalo.so
# Building Framework
# Copy base framework
rm -fr build/Output/AloSDK.framework
cp -a build/Build/Products/Release-iphoneos/AloSDK.framework build/Output/

# Merging binaries
lipo -create "build/Build/Products/Release-iphoneos/AloSDK.framework/AloSDK" "build/Build/Products/Release-iphonesimulator/AloSDK.framework/AloSDK" -output build/Output/AloSDK_Lipo
rm -fr build/Output/AloSDK.framework/AloSDK
mv build/Output/AloSDK_Lipo build/Output/AloSDK.framework/AloSDK
rm -fr build/Output/AloSDK.framework/Frameworks

# Merging swift docs
cp -a build/Build/Products/Release-iphonesimulator/AloSDK.framework/Modules/AloSDK.swiftmodule/* build/Output/AloSDK.framework/Modules/AloSDK.swiftmodule/

# Copying dSYM
cp -a build/Build/Products/Release-iphoneos/AloSDK.framework.dSYM/* build/Output/AloSDK.framework.dSYM/

# Making Bundle
mkdir -p build/Podspec/

# Compressing Framework
rm -fr build/Podspec
mkdir -p build/Podspec/AloSDK.framework
mkdir -p build/Podspec/AloSDK.framework.dSYM
cp -r build/Output/AloSDK.framework build/Podspec/

rm -fr build/Output/ActorSDK.framework/libswiftRemoteMirror.dylib

cp -r build/Output/AloSDK.framework.dSYM build/Podspec/
cp -r Template/ build/Podspec/

cd build/Podspec/
rm -f AloSDK.zip
zip -r AloSDK.zip *
mv AloSDK.zip ../
