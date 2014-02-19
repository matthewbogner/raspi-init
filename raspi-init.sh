#!/bin/bash
# 
# /boot/raspi-init.sh
#
# This script is executed by /etc/init.d/raspi-init
#
# By default this script does nothing, and removes itself after the first run

# This setting will cause this script to exit if there are any errors.
set -ue

disable_after_first_run(){
  if [[ $CALLED_BY == init && $0 == /boot/raspi-init.sh ]]; then
    mv $0 $0.removed_after_first_run
    chkconfig raspi-init off
  fi
}


# Do some custom initializations.
logger "raspi-init: Hello! I'm Raspi Init. I'm here to warm up your pi!"

# Setup wifi
logger "raspi-init: Creating wifi connection..."
nmcli dev wifi connect myssid password mypwd

# Create a non-root user and change the root pwd
logger "raspi-init: Creating new user and changing root pwd..."
password="!!"
useradd --create-home --groups wheel --password $password myusername
usermod --password $password root

# Disable login by root via ssh user directly
logger "raspi-init: Disabling root login via ssh..."
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
service sshd restart

# Shutdown and disable sendmail - no relays here
logger "raspi-init: Disabling sendmail..."
service sendmail stop
chkconfig sendmail off

# Prepare all the time stuffs
logger "raspi-init: Changing timezone..."
unalias cp || echo "No alias found"
cp -f /usr/share/zoneinfo/GMT /etc/localtime

logger "raspi-init: Installing and configuring NTP..."
yum -y install ntp

chkconfig ntpd on
service ntpd start


disable_after_first_run