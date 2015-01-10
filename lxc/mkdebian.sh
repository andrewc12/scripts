#!/bin/bash

container=$1
SUITE=wheezy lxc-create -n $container -t debian
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


#chroot /var/lib/lxc/$container/rootfs/ bin/bash
chroot /var/lib/lxc/$container/rootfs/ apt-get update
chroot /var/lib/lxc/$container/rootfs/ apt-get install openssh-server -y
chroot /var/lib/lxc/$container/rootfs/ passwd
chroot /var/lib/lxc/$container/rootfs/ adduser andrew
#chroot /var/lib/lxc/$container/rootfs/ passwd andrew











