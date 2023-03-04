#!/bin/bash

UpFileName=upfile.iso
UpFileSize=$(( ( RANDOM % 1000 ) +500 ))M
LogDir=/opt/script/logs
LogFile=script-$(date +%s).log

SshPort=2222
SshUser=username
ServerAddr=myserver

UpDir=/opt/script/mainservername

BwLimit=2000


#Create a file of some desired size
truncate -s $UpFileSize $ScriptDir/$UpFileName

# Delete the file if it exists on destination
ssh -p $SshPort $SshUser@$ServerAddr "rm -f $UpDir/$UpFileName"

# Send the file [again]
rsync -v -e "ssh -p $SshPort" --progress --bwlimit=$BwLimit $ScriptDir/$UpFileName $SshUser@$ServerAddr:$UpDir >> $LogDir/$LogFile