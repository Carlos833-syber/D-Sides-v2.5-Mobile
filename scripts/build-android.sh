#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${ANDROID_SDK:=${ANDROID_HOME:?Set ANDROID_HOME or ANDROID_SDK to your SDK directory}}"
: "${ANDROID_NDK_ROOT:=$ANDROID_SDK/ndk/21.4.7075529}"
: "${JAVA_HOME:?Set JAVA_HOME to JDK 11}"
export ANDROID_SDK ANDROID_NDK_ROOT JAVA_HOME
export ANDROID_SETUP=true
haxelib run lime build android -armv7 -arm64 "$@"
