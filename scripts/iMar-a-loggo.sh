#!/bin/bash
#Variables

ready_to_ssh=false
MSSH="ssh -o ControlPath=./control" 
cleanup(){
    $MSSH -O exit "root@$ip"
}

# Get the Device IP Address
if [ $1 = "-help" ]
then
    echo "run script with -pre flag before your border seach and run script with -post after."
else
    # Check SSH Connection
    read -p "what is your device's IP Address? " ip
    echo "Thanks. Trying to SSH into $ip"

    if $MSSH -MNf "root@$ip" 
    then 
        echo Great, looking for Power Logs...
        ready_to_ssh=true
        trap cleanup EXIT
    else
        echo "be sure your device is rooted and connected to the network." 
        
    fi  

    # SSH into Machine and find Power Logs
    if [ $ready_to_ssh = true ]
    then 
        file=$($MSSH "root@$ip" 'find / -name CurrentPowerlog.PLSQL')
        echo The Logs we are looking for are located here: $file
    fi

    # If file actually exists extract the table as a csv for parsing.  If this
    if [ $1 = "-pre" ]
    then
        if [ $file ]
        then
            echo Now, I am going to extract the CurrentPowerlog Aggregate_AppRunTime table into a csv for you.
            $MSSH "root@$ip" "sqlite3 -header -csv $(printf %q "$file") 'SELECT BundleID, sum (ScreenOnTime) as ScreenTime from PLAppTimeService_Aggregate_AppRunTime GROUP BY BundleID;'" > pre-search.csv     
        fi
    elif [ $1 = "-post" ]
    then
        if [ $file ]
        then
            echo Great, I am going to extract the CurrentPowerlog Aggregate_AppRunTime table into a csv for you.
            $MSSH "root@$ip" "sqlite3 -header -csv $(printf %q "$file") 'SELECT BundleID, sum (ScreenOnTime) as ScreenTime from PLAppTimeService_Aggregate_AppRunTime GROUP BY BundleID;'" > post-search.csv     
        fi
    else
        echo Sorry.  Please specify if this is pre-search or post-search
    fi
    #Finally diff the two files.
    if [ $1 = "-post" ]
    then
        git diff pre-search.csv post-search.csv
    fi
fi













