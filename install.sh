#!/bin/bash
# Edit this file to match your folders

echo -e "\n************"
echo      "Uninstalling"
echo      "************"
adb uninstall com.couchbase.callback
echo -e "\n**********"
echo      "Installing"
echo      "**********"
adb install bin/Tangerine-debug.apk
