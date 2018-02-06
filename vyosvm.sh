#!/bin/bash

### This script will spin up a vyOS VM pretty quickly.
### Fred Tesche 2017 fred@fakecomputermusic.com

if [ $# -eq 0 ]; then
	echo "No .iso file specified. Enter URL to grab a freshie: "
	read imageURL
	imageFile=${imageURL##*/}
	imageFileFullPath=~/Downloads/$imageFile
	echo $imageFileFullPath
	curl -o $imageFileFullPath $imageURL
else
	imageFileFullPath=$1
	imageFile=${imageFileFullPath##*/}
	echo $imageFileFullPath
	echo $imageFile
fi

### Set some handy variables
echo "Enter a name for this vyOS VM: "
read vmName
vmFolder="$(VBoxManage list systemproperties | grep "Default machine folder:" | awk '{ print$4" "$5 }')"
vmFullPath="$vmFolder/$vmName"

### Create the VM and primary storage
VBoxManage createvm --name $vmName --ostype "Debian_64" --register
VBoxManage createmedium --filename "$vmFullPath/$vmName.vdi" --size 2048

### Add storage controller, mount install iso, attach primary storage
VBoxManage storagectl $vmName --name "SATA" --add sata --controller IntelAHCI
VBoxManage storageattach $vmName --storagectl "SATA" --port 0 --device 0 --type dvddrive --medium $imageFileFullPath
VBoxManage storageattach $vmName --storagectl "SATA" --port 1 --device 0 --type hdd --medium "$vmFullPath/$vmName.vdi"

### Set some settings
VBoxManage modifyvm $vmName --ioapic on
VBoxManage modifyvm $vmName --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage modifyvm $vmName --memory 512 --vram 128
VBoxManage modifyvm $vmName --nic1 bridged --bridgeadapter1 en0
VBoxManage modifyvm $vmName --audio none

### Fire it up
#VBoxManage startvm $vmName --type headless
VBoxManage startvm $vmName
vBoxManage controlvm $vmName keyboardputscancode 1c 9c
echo "Waiting a little bit for the machine to finish booting..."
sleep 40

#type vyos for username and password
VBoxManage controlvm $vmName keyboardputscancode 2f af #v
VBoxManage controlvm $vmName keyboardputscancode 15 95 #y
VBoxManage controlvm $vmName keyboardputscancode 18 98 #o
VBoxManage controlvm $vmName keyboardputscancode 1f 9f #s
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
VBoxManage controlvm $vmName keyboardputscancode 2f af #v
VBoxManage controlvm $vmName keyboardputscancode 15 95 #y
VBoxManage controlvm $vmName keyboardputscancode 18 98 #o
VBoxManage controlvm $vmName keyboardputscancode 1f 9f #s
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
vBoxManage controlvm $vmName keyboardputscancode 17 97 #i
vBoxManage controlvm $vmName keyboardputscancode 31 b1 #n
VBoxManage controlvm $vmName keyboardputscancode 1f 9f #s
vBoxManage controlvm $vmName keyboardputscancode 14 94 #t
vBoxManage controlvm $vmName keyboardputscancode 1e 9e #a
vBoxManage controlvm $vmName keyboardputscancode 26 a6 #l
vBoxManage controlvm $vmName keyboardputscancode 26 a6 #l
vBoxManage controlvm $vmName keyboardputscancode 39 b9 #space
vBoxManage controlvm $vmName keyboardputscancode 17 97 #i
vBoxManage controlvm $vmName keyboardputscancode 32 b2 #m
vBoxManage controlvm $vmName keyboardputscancode 1e 9e #a
vBoxManage controlvm $vmName keyboardputscancode 22 a2 #g
vBoxManage controlvm $vmName keyboardputscancode 12 92 #e
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
sleep 1
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
sleep 1
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
sleep 1
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
sleep 1
vBoxManage controlvm $vmName keyboardputscancode 15 95 #y
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
sleep 5
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
sleep 1
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
sleep 1
VBoxManage controlvm $vmName keyboardputscancode 2f af #v
VBoxManage controlvm $vmName keyboardputscancode 15 95 #y
VBoxManage controlvm $vmName keyboardputscancode 18 98 #o
VBoxManage controlvm $vmName keyboardputscancode 1f 9f #s
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
VBoxManage controlvm $vmName keyboardputscancode 2f af #v
VBoxManage controlvm $vmName keyboardputscancode 15 95 #y
VBoxManage controlvm $vmName keyboardputscancode 18 98 #o
VBoxManage controlvm $vmName keyboardputscancode 1f 9f #s
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
sleep 1
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
VBoxManage controlvm $vmName keyboardputscancode 19 99 #p
VBoxManage controlvm $vmName keyboardputscancode 18 98 #o
VBoxManage controlvm $vmName keyboardputscancode 11 91 #w
vBoxManage controlvm $vmName keyboardputscancode 12 92 #e
vBoxManage controlvm $vmName keyboardputscancode 13 93 #r
VBoxManage controlvm $vmName keyboardputscancode 18 98 #o
VBoxManage controlvm $vmName keyboardputscancode 21 b1 #f
VBoxManage controlvm $vmName keyboardputscancode 21 b1 #f
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
VBoxManage controlvm $vmName keyboardputscancode 15 95 #y
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter

### Wait a little bit for shutdown
sleep 20

### Remove the install iso, reboot
vBoxManage storageattach $vmName --storagectl "SATA" --port 0 --device 0 --type dvddrive --medium none

### Fire it up
#VBoxManage startvm $vmName --type headless
VBoxManage startvm $vmName
echo "Waiting for VM to reboot..."
sleep 60

#type vyos for username and password
VBoxManage controlvm $vmName keyboardputscancode 2f af #v
VBoxManage controlvm $vmName keyboardputscancode 15 95 #y
VBoxManage controlvm $vmName keyboardputscancode 18 98 #o
VBoxManage controlvm $vmName keyboardputscancode 1f 9f #s
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
VBoxManage controlvm $vmName keyboardputscancode 2f af #v
VBoxManage controlvm $vmName keyboardputscancode 15 95 #y
VBoxManage controlvm $vmName keyboardputscancode 18 98 #o
VBoxManage controlvm $vmName keyboardputscancode 1f 9f #s
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter

### todo: Give first interface an IP, then ssh in.
