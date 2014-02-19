#!/bin/bash

###################
# 
# Copyright 2014 Matthew Bogner (matt at ibogner.net)
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
###################
#
# This work was heavily inspired by the notion of a cloud-init script started by the Ubuntu community
# and later adopted by AWS EC2 Amazon Linux AMIs.  The desire to have such a thing for Raspberry Pi 
# was bolstered further by the work of Richard Bronosky here: https://github.com/RichardBronosky/raspbian-boot-setup
# 
# This script is intended to be executed from within a Vagrant virtual machine.  I develop locally on a Mac, 
# which is unable to read & write ext4 filesystems in a sane manner. 
#
# This script currently supports RedHat/Fedora style init services (i.e. pidora)
#
# I use this script in the following manner:
#     
#      Step 1: Author custom first-boot script (raspi-init.sh) in same folder as Vagrantfile
#      Step 2: Repackage the Pidora distro to run the raspi-init.sh the first time it boots      
#         macbook:~$ vagrant up
#         macbook:~$ vagrant ssh
#         vagrant:~$ cd /vagrant
#         vagrant:/vagrant$ sudo ./create-modified-disk-image.sh http://pidora.ca/pidora/releases/18/images/pidora-18-r2c.zip
#         vagrant:/vagrant$ exit
#      Step 3: Copy the customized image to the SD card (takes maybe 15min to copy 1.7GB)
#         macbook:~$ dd if=pidora-18-r2c.img of=/dev/disk2 bs=4m

set -ue

# Create a tmp working dir
mkdir -p /vagrant/working
cd /vagrant/working

# just in case it was already mounted, unmount the image
umount /mnt/distro || echo "Not able to unmount"

# Download the image if we don't already have it locally
if [ ! -e image.zip ]; then
    wget -O image.zip $1
else
    # We already have it - remove any .img files so we don't get confused when we unpack the zip again
    rm -rf *.img
fi

# Unzip the image
unzip image.zip

# Ditch the md5sum file.  Yea, I know... whatevs
rm -rf *.md5sum

# Find the disk image filename
imgFile=$(ls *.img)

# Find the offsets of the various filesystems in the image
echo "Finding partition offsets in disk image..."
bootFSOffset=$(parted $imgFile unit B print | grep boot | awk '{print $2}' | tr -d 'B')
rootFSOffset=$(parted $imgFile unit B print | grep ext4 | awk '{print $2}' | tr -d 'B')

# Create an empty destination upon which we can mount the disk image
rm -rf /mnt/distro
mkdir -p /mnt/distro

# Mount the disk image
echo "Mounting root partition..."
mount -o loop,rw,offset=$rootFSOffset $imgFile /mnt/distro

# Now we can do whatever work we need in the /mnt/distro dir 
echo "Doing some hacking.  Can you hand me the socket wrench?"
cp /vagrant/raspi-init /mnt/distro/etc/init.d/raspi-init
chmod 0755 /mnt/distro/etc/init.d/raspi-init
ln -s /mnt/distro/etc/init.d/raspi-init /mnt/distro/etc/rc.d/rc0.d/K95raspiinit

# Now that we're done modifying the image, unmount it
echo "Unmounting root partition..."
umount /mnt/distro

# Mount the boot partition of the disk image to add the headless file and actual boot script
echo "Mounting boot partition to load in the raspi-init.sh script and headless file..."
mount -o loop,rw,offset=$bootFSOffset $imgFile /mnt/distro

echo "Defining headless file..."
echo "RESIZE" > /mnt/distro/headless
echo "SWAP=512" >> /mnt/distro/headless

echo "Copying in the raspi-init.sh script..."
cp /vagrant/raspi-init.sh /mnt/distro/raspi-init.sh
chmod 0755 /mnt/distro/raspi-init.sh

# Unmount the boot partition
echo "Unmounting boot partition..."
umount /mnt/distro

# Rename the image file to denote "doneness"
mv $imgFile $imgFile.modified.img
echo "Done"
