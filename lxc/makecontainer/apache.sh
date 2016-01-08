#!/bin/sh
CONTAINER=apache
#Create container
../mkdebianmenu.sh -B none -n $CONTAINER -r jessie 
#In fstab


lxc-start -n $CONTAINER -d
#chroot /var/lib/lxc/$container/rootfs/ bin/bash

sleep 20
lxc-attach -n $CONTAINER -- apt-get install apache2 apache2-doc -y
lxc-attach -n $CONTAINER -- apt-get install php5 php5-mysql libapache2-mod-php5 -y

lxc-stop -n $CONTAINER

cat >> /var/lib/lxc/$CONTAINER/fstab << EOF
/storage storage none bind,create=dir
EOF



exit 0
