#!/usr/bin/env bash

rm -rf logs
adb pull /sdcard/TouchSprite/log logs
#adb logcat -d > logs/1.log
