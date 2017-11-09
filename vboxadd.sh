#!/bin/bash

echo "Installing VirtualBox Additions"
apt-get -y install x11-xserver-utils
apt-get -y install linux-headers-$(dpkg --print-architecture)
sh ../VBoxLinuxAdditions.run
