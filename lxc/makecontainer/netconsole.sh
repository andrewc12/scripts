#!/bin/sh
CONTAINER=netconsole
#Create container
../mkdebianmenu.sh -B none -n $CONTAINER -r jessie 
#In fstab


lxc-start -n $CONTAINER -d
#chroot /var/lib/lxc/$container/rootfs/ bin/bash

sleep 20
lxc-attach -n $CONTAINER -- apt-get install netcat-openbsd -y

cat > /var/lib/lxc/$CONTAINER/rootfs/etc/network/interfaces << EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 10.0.0.2
    netmask 255.255.255.0
    network 10.0.0.0
    broadcast 10.0.0.255
    gateway 10.0.0.138
    dns-nameservers 10.0.0.138
EOF


lxc-stop -n $CONTAINER

cat >> /var/lib/lxc/$CONTAINER/fstab << EOF
/storage storage none bind,create=dir
EOF



exit 0
