#!/bin/bash

UpFileName=upfile.iso
UpFileSize=$(( ( RANDOM % 1000 ) +500 ))M

#Variables that need to be defined based on your environment and needs
LogDir=/opt/upscript/logs
LogFile=upscript-$(date +%s).log

SshPort=2222
SshUser=username
ServerAddr=myserver

UpDir=/opt/upscript/mainservername

BwLimit=2000


#Create a file of some desired size
truncate -s $UpFileSize $ScriptDir/$UpFileName

# Delete the file if it exists on destination
ssh -p $SshPort $SshUser@$ServerAddr "rm -f $UpDir/$UpFileName"

# Send the file [again]
rsync -v -e "ssh -p $SshPort" --progress --bwlimit=$BwLimit $ScriptDir/$UpFileName $SshUser@$ServerAddr:$UpDir >> $LogDir/$LogFile