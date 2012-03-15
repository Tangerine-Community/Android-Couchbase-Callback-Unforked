#!/bin/bash
# Edit this file to match your folders
ant clean
ant debug
adb uninstall com.couchbase.callback
adb install /Users/fet/Sites/Android-Couchbase-Callback/bin/AndroidCouchbaseCallback-debug.apk
adb shell am start -n com.couchbase.callback/.AndroidCouchbaseCallback
