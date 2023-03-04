#!/bin/bash

UpFileName=ubuntu2204x64.iso
ScriptDir=/opt/script
LogDir=/opt/script/logs
LogFile=script-$(date +%s).log

SshPort=2222
SshUser=username
ServerAddr=myserver

UpDir=/opt/script/mainservername

BwLimit=2000

ssh -p $SshPort $SshUser@$ServerAddr "rm -f $UpDir/$UpFileName"

rsync -v -e "ssh -p $SshPort" --progress --bwlimit=$BwLimit $ScriptDir/$UpFileName $SshUser@$ServerAddr:$UpDir >> $LogDir/$LogFile