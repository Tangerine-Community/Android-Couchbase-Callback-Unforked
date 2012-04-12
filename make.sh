#!/bin/bash
# Edit this file to match your folders

BACKUP="tangerine-apks"
if [ ! -d "$BACKUP" ]; then
mkdir $HOME/$BACKUP
fi


echo
echo "********"
echo "Cleaning"
echo "********"
ant clean
# ant debug clean
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
adb install bin/Tangerine-debug.apk
echo
echo "**********"
echo "Backing up to $HOME/$BACKUP"
echo "**********"


NOW=$(date +"%Y%m%d-%H")
FILE="Tangerine-debug.$NOW.tar.gz"
tar czfv $FILE bin/Tangerine-debug.apk
cp -f $FILE $HOME/$BACKUP 
rm $FILE
#adb shell am start -n com.couchbase.callback/.AndroidCouchbaseCallback
