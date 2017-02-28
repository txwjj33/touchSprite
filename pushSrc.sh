#!/usr/bin/env bash
srcpath=/sdcard/TouchSprite/lua
adb shell rm -r $srcpath
adb push lua $srcpath
