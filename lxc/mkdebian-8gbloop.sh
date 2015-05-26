#!/bin/bash

container=$1
mkdir /var/lib/lxc/$container
touch /var/lib/lxc/$container/rootdev
SUITE=wheezy lxc-create -B loop --fstype ext4 -n $container -t debian -o log --logpriority=7
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



truncate -s8G /var/lib/lxc/$container/rootdev
e2fsck -f /var/lib/lxc/$container/rootdev && resize2fs /var/lib/lxc/$container/rootdev









