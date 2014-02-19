raspi-init
============================

Creates a basic vagrant build box with all fo the necessary tools for doing non-Mac type tasks, like reading & writing EXT4 filesystems. 

I use this Vagrant to create customized Pidora Raspberry Pi disk images to bootstrap a new installation w/ a basic set of configuration. 

This work was heavily inspired by the notion of a cloud-init script started by the Ubuntu community
and later adopted by AWS EC2 Amazon Linux AMIs.  The desire to have such a thing for Raspberry Pi 
was bolstered further by the work of Richard Bronosky here: https://github.com/RichardBronosky/raspbian-boot-setup

This script is intended to be executed from within a Vagrant virtual machine.  I develop locally on a Mac, 
which is unable to read & write ext4 filesystems in a sane manner. 

This script currently supports RedHat/Fedora style init services (i.e. pidora)

I use this script in the following manner:
     
      Step 1: Author custom first-boot script (raspi-init.sh) in same folder as Vagrantfile
      Step 2: Repackage the Pidora distro to run the raspi-init.sh the first time it boots      
         macbook:~$ vagrant up
         macbook:~$ vagrant ssh
         vagrant:~$ cd /vagrant
         vagrant:/vagrant$ sudo ./create-modified-disk-image.sh http://pidora.ca/pidora/releases/18/images/pidora-18-r2c.zip
         vagrant:/vagrant$ exit
      Step 3: Copy the customized image to the SD card (takes maybe 15min to copy 1.7GB)
         macbook:~$ dd if=pidora-18-r2c.img of=/dev/disk2 bs=4m
