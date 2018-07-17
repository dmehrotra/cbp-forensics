#!/bin/bash
#Variables

if [ $1 = "-help" ]
then
    echo "run script with -pre flag before your border seach and run script with -post after."
else
    if [ $1 = "-pre" ]
    then
        echo dumping usage stats to pre-search.txt
        adb shell dumpsys usagestats > pre-search.txt
        if [ $? != 0 ]
        then
            echo have you installed adb and connected your device to the computer?    
        fi
    elif [ $1 = "-post" ]
    then 
        echo dumping usage stats to post-search.txt
        adb shell dumpsys usagestats > post-search.txt
        if [ $? != 0 ]
        then
            echo have you installed adb and connected your device to the computer?
        fi 
        git diff pre-search.txt post-search.txt
    else
        echo "-help for more info"
    fi
fi













