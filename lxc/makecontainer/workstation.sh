#!/bin/sh
CONTAINER=workstation
#Create container
../mkdebianmenu.sh -B none -n $CONTAINER -r jessie 
#In fstab


lxc-start -n $CONTAINER -d
#chroot /var/lib/lxc/$container/rootfs/ bin/bash

sleep 20
lxc-attach -n $CONTAINER -- apt-get install git build-essential apt-build fakeroot -y

cat > /var/lib/lxc/$CONTAINER/rootfs/hone/andrew/.gitconfig << EOF
[user]
        name = Andrew Innes
        email = andrew.c12@gmail.com
EOF


lxc-stop -n $CONTAINER

cat >> /var/lib/lxc/$CONTAINER/fstab << EOF
/storage storage none bind,create=dir
EOF



exit 0
