# **Automated Upload Timer**

This repo consists of a simple `rsync` script and a `systemd` service and timer component to frequently upload a file to a destination server at a timely interval.

The purpose is to increase the upload stats on a server or a network connection where the ISP or Datacenter requires the uploaded data be much more than the downloaded data. That might sound weird to some people but there are such providers in some "free" countries on this planet who would limit your bandwidth if your download is more than your upload because they wouldn't want people to run VPN servers on their infrustructure!

I'm gonna write these instructions for the people who might not have much experience with Linux machines, so some parts might sound too obvious to the more advanced users, I ask your majesty's forgiveness beforehand!

The terms that are probably gonna be used a lot in the following instructions are these:
- **Main Server:** This is the server that's on the sh**ty network that limits people's bandwidth!
- **Destination Server:** This would be the server that you're connecting and uploading to.


## **Instructions**

First of all I suggest for the ease of your job, add the IP address of the destination server to your `/etc/hosts` file.

```sh
#IP         friendlyname
1.2.3.4     myserver
```

Second thing that should be done is to authorize the Main Server to SSH into the Destination Server using an SSH Public Key.

On the Main Server run:
```sh
ssh-keygen
```
Press Enter until the process ends.

Then copy the contents of the file `id_rsa.pub`
```sh
cat ~/.ssh/id_rsa.pub
```

SSH into the Destination Server, open the `authorized_keys` file for the user that you're gonna SSH into with a text editor.
```sh
vim ~/.ssh/authorized_keys
```
Paste the contents that you copied in the previous step into a new line.



### **Script Setup**

Then go back to the amin server, create a directory somewhere for the script file and the logs. I use the following paths for the examples:
```sh
#Script Directory
/opt/script/
#Logs Directory
/opt/script/logs/
```

This script automatically creates a file of the defined size `UpFileSize`, or you could download a relatively large file yourself, like Ubuntu's ISO image!

Copy the file `script.sh` to the script directory and replace the following variables with correct information about your server and paths:
```sh
UpFileName=upfile.iso
UpFileSize=1600M
LogDir=/opt/script/logs
LogFile=script-$(date +%s).log

SshPort=2222
SshUser=username
ServerAddr=myserver

UpDir=/opt/script/mainservername

BwLimit=2000
```
Notice that the values starting with `Ssh` should be filled with the connection information for the Destination Server.

`BwLimit` is the upload rate in *Kilo Bytes Per Second*. It will limit the upload rate so that `rsync` wouldn't employ the whole upload bandwidth of the server which might cause other issues such as network inaccessibilty during the upload or cause your service to get suspended due to using too much resources at a time!


### **Service and Timer Setup**
Okay, now we're setting up the `systemd` Service and Timer to run the script with a time interval in between, here 26 minutes after the previous run was finished.

First create 2 file called `upscript.service` and `upscript.time` in the `systemd` directory:
```sh
sudo touch /etc/systemd/system/upscript.service
sudo touch /etc/systemd/system/upscript.timer
```

Then edit the Service file and paste the contents of the `upscript.service` file into it:
```sh
sudo vim /etc/systemd/system/upscript.service
```
Note that you should set the following variables in that file to fit your directories, paths, and username:
```conf
User=username
Group=usergroup
ExecStart=bash /opt/script/script.sh
StandardOutput=file:/opt/script/logs/script.log
StandardError=file:/opt/script/logs/script-error.log
```

Then edit the Timer file and paste the contents of the `upstript.timer` file into it:
```sh
sudo vim /etc/systemd/system/upscript.timer
```
Note that you can change these variable as you desire:
```conf
OnUnitInactiveSec=26m
OnBootSec=33m
```
`OnUnitInactiveSec` here means that 26 minutes after the past upload was finished, a new one would be started. This prevents overlaps (compared to OnUnitActive).

At the end, run the following commands:
```sh
sudo systemctl daemon-reload
sudo systemctl enable upscript.timer
```

### **Final Tests and Notes**
You should test the SSH connection to your destination server and accept the SSH key on your main server at least once manually.
```sh
ssh -p port username@myserver
```

You could trigger the run manually via running either of these:
```sh
sudo systemctl start upscript.service
bash /opt/script/script.sh
# And Tail the logfile to see the progress:
# tail -f /opt/script/logs/script-newesttime.log
```

Every run of the script leaves a log file inside the `LogDir` named using the Unix timestamp of the time of run.
This is for the sake of debugging and log checks; you could run a `logrotate` service or manually delete them as they'd increase in number over time! Or you could disable it by commenting out this part inside `script.sh`:
```sh
# >> $LogDir/$LogFile
```

#### **Stuff To Do On The Destination Server**

Something else that you obviously should do on the destination server is to create the `UpDir` on it and give write permission to the user that SSHes into that server!

Also if your destination server is low on storage, you could easily add a Cronjob to look for the uploaded file every few minutes and if it exists, delete it:

```sh
*/10 * * * * rm -f /opt/script/*/upfile.iso
```
This will delete any file called `upfile.iso` inside any folder under the directory `/opt/script/` every 10 minutes!

### **Okay, that's it! Good Luck with your endevours! :))**