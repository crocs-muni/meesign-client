#!/bin/bash

if [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "Invalit ANDROID_NDK_HOME path!"
    exit 1
fi
if [ -z "$ANDROID_API" ]; then
    echo "ANDROID_API not set!"
    exit 2
fi

TARGETS="
aarch64-linux-android
armv7-linux-androideabi
x86_64-linux-android
i686-linux-android
"

for TARGET in $TARGETS; do
    echo "[target.$TARGET]"
    echo "linker = \"$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/${TARGET/armv7/armv7a}$ANDROID_API-clang\""
    echo
done
