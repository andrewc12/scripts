#!/bin/bash
# ---------------------------------------------------------------------------
# name - Description

# Copyright 2015, Andrew Innes <andrew.c12@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.

# Usage: new_script [-h|--help] [-q|--quiet] [-s|--root] [script]

# Revision history:
# 2015-04-12  Created
# ---------------------------------------------------------------------------

while getopts "B:n:r:" opt; do
  case $opt in
    B)
      echo "-a was triggered, Parameter: $OPTARG" >&2
      BSTORE=$OPTARG
      ;;
    n)
      echo "-a was triggered, Parameter: $OPTARG" >&2
      container=$OPTARG
      ;;
    r)
      echo "-a was triggered, Parameter: $OPTARG" >&2
      RELEASE=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
source ./actwelve.sh
if [[ -z "$RELEASE" ]]; then
f_actwelve_chooseDebianRelease RELEASE || exit 1
fi
if [[ -z "$BSTORE" ]]; then
f_actwelve_chooseLxcBackingStore BSTORE || exit 1
fi
if [[ -z "$container" ]]; then 
f_actwelve_chooseLxcName container || exit 1
fi

lxc-create -B $BSTORE  -n $container -t debian -- -r $RELEASE





cat >> /var/lib/lxc/$container/config << EOF
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.name = eth0
#lxc.start.auto = 1
#lxc.start.delay = 0
EOF

macaddr=$(echo $container|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')
echo "lxc.network.hwaddr = $macaddr" >> /var/lib/lxc/$container/config
echo "lxc.network.hwaddr = $macaddr"

lxc-start -n $container -d
#chroot /var/lib/lxc/$container/rootfs/ bin/bash

sleep 20
#chroot /var/lib/lxc/$container/rootfs/
lxc-attach -n $container -- apt-get update
#chroot /var/lib/lxc/$container/rootfs/ 
lxc-attach -n $container -- apt-get install openssh-server -y
#chroot /var/lib/lxc/$container/rootfs/ 
lxc-attach -n $container -- passwd
#chroot /var/lib/lxc/$container/rootfs/ 
lxc-attach -n $container -- adduser andrew
#chroot /var/lib/lxc/$container/rootfs/ passwd andrew
lxc-stop -n $container








exit 0



































container=$1
mkdir /var/lib/lxc/$container
touch /var/lib/lxc/$container/rootdev
SUITE=wheezy lxc-create -B loop --fstype ext4 -n $container -t debian -o log -- -r jessie
#SUITE=wheezy lxc-create -B loop  -n $container -t debian


#Now we need to tell to the container that he have to connect to #this bridge interface, so open your container configuration #file, located at /var/lib/lxc/$Container_Name/config and add #those line to this file:

cat >> /var/lib/lxc/$container/config << EOF
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.name = eth0
#lxc.start.auto = 1
#lxc.start.delay = 0
EOF

macaddr=$(echo $container|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')
echo "lxc.network.hwaddr = $macaddr" >> /var/lib/lxc/$container/config
echo "lxc.network.hwaddr = $macaddr"


lxc-start -n $container -d
#chroot /var/lib/lxc/$container/rootfs/ bin/bash

sleep 20
#chroot /var/lib/lxc/$container/rootfs/
lxc-attach -n $container -- apt-get update
#chroot /var/lib/lxc/$container/rootfs/ 
lxc-attach -n $container -- apt-get install openssh-server -y
#chroot /var/lib/lxc/$container/rootfs/ 
lxc-attach -n $container -- passwd
#chroot /var/lib/lxc/$container/rootfs/ 
lxc-attach -n $container -- adduser andrew
#chroot /var/lib/lxc/$container/rootfs/ passwd andrew
lxc-stop -n $container









#truncate -s8G /var/lib/lxc/$container/rootdev
#e2fsck -f /var/lib/lxc/$container/rootdev && resize2fs /var/lib/lxc/$container/rootdev



#!/bin/bash

container=$1
SUITE="wheezy" MIRROR="http://aptcache:3142/ftp.debian.org/debian" lxc-create -n $container -t debian
#SUITE=wheezy lxc-create -B loop  -n $container -t debian


#Now we need to tell to the container that he have to connect to #this bridge interface, so open your container configuration #file, located at /var/lib/lxc/$Container_Name/config and add #those line to this file:

cat >> /var/lib/lxc/$container/config << EOF
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.name = eth0
#lxc.start.auto = 1
#lxc.start.delay = 0
EOF

macaddr=$(echo $container|md5sum|sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')
echo "lxc.network.hwaddr = $macaddr" >> /var/lib/lxc/$container/config
echo "lxc.network.hwaddr = $macaddr"

cat > /var/lib/lxc/$container/rootfs/etc/apt/apt.conf << EOF
Acquire::http { Proxy "http://aptcache:3142"; };
EOF
cat > /var/lib/lxc/$container/rootfs/etc/apt/sources.list << EOF
deb http://ftp.debian.org/debian wheezy main
EOF



#chroot /var/lib/lxc/$container/rootfs/ bin/bash
chroot /var/lib/lxc/$container/rootfs/ apt-get update
chroot /var/lib/lxc/$container/rootfs/ apt-get install openssh-server -y
chroot /var/lib/lxc/$container/rootfs/ passwd
chroot /var/lib/lxc/$container/rootfs/ adduser andrew
#chroot /var/lib/lxc/$container/rootfs/ passwd andrew


chroot /var/lib/lxc/$container/rootfs/ "mkdir -pm 700 /root/.ssh && echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAiP0arxywVo1ZRtgb3cyKxwDtVBREsyYO2pIU5Qwb6/MCU1js0Q3U7vW0XfL4j1/BlJu83QHyvbCpt7XZW6THWcNUuNHBJLpZE/1nU5Z+kOcxFpX6M6ZB43/gLsZDU6ZV4qBmDW7FcBv4PUWQkIH1iQUCaJS6mhRpc9BdSDYaaisdurQkwzE5iEOGZJ4V6MoHSoskMilxe6rhkZpt5ZJ868YSNngT2i06ECkZizj7zDswWx9NezTBDrntFOqxjIUznvwcnAUVv9Q2Qvj1YMhjY1Mca6fKdqr8dea5VIyDItN4G4wShQ7J/4dupzrbeXhaKgsnnwNR32OWBTbgUW+8nTCbwOr5yi0BqQSCpVSKvGo4dee2/Ywt4eecU9VE1DE8+5hyCCPUtcWsBUhfU5o5eW4FyUr8rh6AkbzDR/YxrUzhO0JAtqe+mwQEIxwbkxkQhaz+w0lC/m97JMCjt2PeswLDq8YjkmT8NyEvyd573ukSBBP276fbOkMkvW/enpRTIyMbxQUHh5gI2yBcC8gSx1wXPihtJrl4KT65fRDKZovkAAr39Fsyeje/Zv2/Nh6YHnU2D6SpNKDa4wBk1aTy4ZTXuI7yfqsfnQS/TM+I/wj5fy+yRx6JNfVwb/9s/9nNYXpaKSwbQzD6trqpVSl/3edb/U9c7RxbELRqBvWNl1M= andrew it03' > /root/.ssh/authorized_keys && chmod 0600 /root/.ssh/authorized_keys && chown -R root:root /root/.ssh"








