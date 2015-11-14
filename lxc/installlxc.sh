#!/bin/sh
apt-get install lxc bridge-utils -y


cat > /etc/network/interfaces << EOF
auto br0
iface br0 inet dhcp
    bridge_ports eth0
    bridge_fd 0
    bridge_maxwait 0
EOF


cat >> /etc/fstab << EOF
cgroup  /sys/fs/cgroup  cgroup  defaults  0   0
EOF

