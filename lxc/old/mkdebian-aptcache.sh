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








