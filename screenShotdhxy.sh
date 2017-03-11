#!/usr/bin/env bash
name=$1
srcPath=/sdcard/screenShot/dhxy
desPath=screenShots/dhxy
adb shell mkdir -p $srcPath
adb shell /system/bin/screencap -p -d 0 $srcPath/$name.png

mkdir -p $desPath
adb pull $srcPath/$name.png $desPath/$name.png
# 以下命令会报:sed: RE error: illegal byte sequence
# adb shell screencap -p | sed 's/\r$//' > $desPath/$name.png
