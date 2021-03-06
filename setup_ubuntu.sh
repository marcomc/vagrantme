#!/bin/bash
# set the hostname
echo "Setting the hosname to $VAGRANT_HOSTNAME"
echo $VAGRANT_HOSTNAME > /etc/hostname
# make sure that the system is updated at the latests release
#
# updates the system
echo "Updating the system"
apt-get -qy update && sudo apt-get -qy dist-upgrade

# install desired packages
echo "Installing OpenSSH, Screen, Make, Git, GCC"
apt-get -qy install openssh-server openssh-client vim screen make git-core gcc

echo "Cleaning the installation cache"
# spring cleaning
apt-get -qy clean
