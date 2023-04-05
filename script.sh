#!/bin/bash

UpFileName=upfile.iso                       # Upload file's name
UpFileSize=$(( ( RANDOM % 1000 ) +500 ))M   # Upload file's size generated randomly between 500MB and 1500MB


## Variables that need to be defined based on your environment and needs

ScriptDir=/opt/upscript                 # The location this script is running!
LogDir=$ScriptDir/logs                  # Logs directory
LogFile=upscript-$(date +%s).log        # Log file format: upscript-unixtime.log

SshPort=2222                            # Destination server SSH port number
SshUser=username                        # Destination server username
ServerAddr=myserver                     # Destination server address or hostname

SenderName=$(hostname)                  # Optional, setting the destination subdirectory name
UpDir=/opt/upscript/$SenderName         # Upload directory on destination server

BwLimit=$(( ( RANDOM % 2000 ) +700 ))   # Bandwidth limit generated randomly between 700KBps and 2700KBps


## Create a file of the desired/random size
truncate -s $UpFileSize $ScriptDir/$UpFileName

## Delete the file if it exists on destination
ssh -p $SshPort $SshUser@$ServerAddr "rm -f $UpDir/$UpFileName"

## Upload the file to the destination server
rsync -v -e "ssh -p $SshPort" --progress --bwlimit=$BwLimit $ScriptDir/$UpFileName $SshUser@$ServerAddr:$UpDir >> $LogDir/$LogFile