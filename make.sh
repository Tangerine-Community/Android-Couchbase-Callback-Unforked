#!/bin/bash
# Edit this file to match your folders

BACKUP="tangerine-apks"
if [ ! -d "$BACKUP" ]; then
mkdir $HOME/$BACKUP > /dev/null
fi


echo -e "\n\nTangerine Make Script\n\n"

read -p "Do you want to delete your current database and start with a clean, new empty one?" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
# Clean out the tangerine DB of any existing assessments or results
echo -e "\n********"
echo      "Deleting local database"
echo      "********"

curl -H "Content-Type: application/json" -X DELETE http://tangerine:tangytangerine@localhost:5984/tangerine; curl -H "Content-Type: application/json" -X PUT http://tangerine:tangytangerine@localhost:5984/tangerine; cd ../app; 

echo -e "\n*********************"
echo      "Pushing with CouchApp"
echo      "*********************"


couchapp push; cd -
fi


echo -e "\n********"
echo      "Cleaning"
echo      "********"
ant clean
# ant debug clean
echo -e "\n********"
echo      "Compacting database"
echo      "********"
curl -X POST -H "Content-Type: application/json" http://tangerine:tangytangerine@localhost:5984/tangerine/_compact
echo -e "\n********"
echo      "Building"
echo      "********"
ant debug
NOW=$(date +"%Y%m%d-%H")
cp bin/Tangerine-debug.apk bin/Tangerine-$NOW.apk
echo -e "\n************"
echo      "Uninstalling"
echo      "************"
adb uninstall com.couchbase.callback
echo -e "\n**********"
echo      "Installing"
echo      "**********"
adb install bin/Tangerine-debug.apk
echo -e "\n**********"
echo      "Backing up to $HOME/$BACKUP"
echo      "**********"


FILE="Tangerine-$NOW.tar.gz"
tar czfv $FILE bin/Tangerine-debug.apk
cp -f $FILE $HOME/$BACKUP 
rm $FILE
#adb shell am start -n com.couchbase.callback/.AndroidCouchbaseCallback
