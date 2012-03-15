#!/bin/bash
# Edit this file to match your folders
echo
echo "********"
echo "Cleaning"
echo "********"
ant clean
echo
echo "********"
echo "Building"
echo "********"
ant debug
echo 
echo "************"
echo "Uninstalling"
echo "************"
adb uninstall com.couchbase.callback
echo
echo "**********"
echo "Installing"
echo "**********"
adb install /Users/fet/Sites/Tangerine/Android-Couchbase-Callback/bin/AndroidCouchbaseCallback-debug.apk
#adb shell am start -n com.couchbase.callback/.AndroidCouchbaseCallback
