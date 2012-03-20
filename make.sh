#!/bin/bash
# Edit this file to match your folders
echo
echo "********"
echo "Cleaning"
echo "********"
ant clean
echo
echo "********"
echo "Compacting database"
echo "********"
curl -X POST -H "Content-Type: application/json" http://tangerine:tangytangerine@localhost:5984/tangerine/_compact
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
adb install /Users/fet/Sites/Tangerine/Android-Couchbase-Callback/bin/Tangerine-debug.apk
#adb shell am start -n com.couchbase.callback/.AndroidCouchbaseCallback
