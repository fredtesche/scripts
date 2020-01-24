#!/bin/bash

### This script will create a VM for Windows Server 2016 pretty quickly.
### Fred Tesche 2017 fred@fakecomputermusic.com

if [ $# -eq 0 ]; then
	echo "Enter path to .iso: "
	read imageFileFullPath
        imageFile=${imageFileFullPath##*/}
else
	imageFileFullPath=$1
	imageFile=${imageFileFullPath##*/}
	echo $imageFileFullPath
	echo $imageFile
fi

### Set some handy variables
echo "Enter a name for this VM: "
read vmName
vmFolder="$(VBoxManage list systemproperties | grep "Default machine folder:" | awk '{ print$4" "$5 }')"
vmFullPath="$vmFolder/$vmName"

### Create the VM and primary storage
VBoxManage createvm --name $vmName --ostype "Windows2016_64" --register
VBoxManage createmedium --filename "$vmFullPath/$vmName.vdi" --size 51200

### Add storage controller, mount install iso, attach primary storage
VBoxManage storagectl $vmName --name "SATA" --add sata --controller IntelAHCI
VBoxManage storageattach $vmName --storagectl "SATA" --port 0 --device 0 --type dvddrive --medium $imageFileFullPath
VBoxManage storageattach $vmName --storagectl "SATA" --port 1 --device 0 --type hdd --medium "$vmFullPath/$vmName.vdi"

### Set some settings
VBoxManage modifyvm $vmName --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage modifyvm $vmName --memory 2048 --vram 128
VBoxManage modifyvm $vmName --nic1 bridged --bridgeadapter1 en0
VBoxManage modifyvm $vmName --audio none
VBoxManage modifyvm $vmName --firmware efi64

### Fire it up
VBoxManage startvm $vmName
sleep 3
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
echo "Pressed enter to boot from DVD"
sleep 20
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
echo "Pressed enter at language selection"
sleep 3
vBoxManage controlvm $vmName keyboardputscancode 17 97 #i
echo "Pressed I at Install Now prompt"
sleep 18
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
echo "Pressed enter to select install type"
sleep 5
vBoxManage controlvm $vmName keyboardputscancode 1e 9e #a
echo "Pressed A to accept EULA"
sleep 1
vBoxManage controlvm $vmName keyboardputscancode 31 b1 #n
echo "Pressed N to hit Next button"
sleep 2
vBoxManage controlvm $vmName keyboardputscancode 2e ae #c
echo "Pressed C to select custom install type"
sleep 2
vBoxManage controlvm $vmName keyboardputscancode 1c 9c #enter
echo "Pressed Enter to begin install"

### Remove the install iso, reboot
#vBoxManage storageattach $vmName --storagectl "SATA" --port 0 --device 0 --type dvddrive --medium none
