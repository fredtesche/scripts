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
vmFolder="$(VBoxManage list systemproperties | grep "Default machine folder:" | awk '{ print$4 }')"
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

### After this we gotta add stuff about booting vyOS and installing.
