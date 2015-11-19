#!/bin/sh
CONTAINER=jump
#Create container
../mkdebianmenu.sh -B none -n $CONTAINER -r jessie 
#In fstab


lxc-start -n $CONTAINER -d
#chroot /var/lib/lxc/$container/rootfs/ bin/bash

sleep 20
lxc-attach -n $CONTAINER -- apt-get install tmux -y

cat > /var/lib/lxc/$CONTAINER/rootfs/home/andrew/.tmux.conf << EOF

set -g status-bg black
set -g status-fg white
setw -g aggressive-resize on
set -g default-terminal "screen-256color"
new -n irc "ssh ircclient"
neww -n workstation "ssh workstation"
neww -n nc "ssh 10.0.0.2"
neww -n lxcbig "ssh lxcbig"
neww -n lxc01 "ssh lxc01"
neww -n dstat "ssh andrew@lxcbig dstat"
splitw -v -p 50 -t :dstat "ssh andrew@nas dstat"
neww
EOF


lxc-stop -n $CONTAINER

cat >> /var/lib/lxc/$CONTAINER/fstab << EOF
/storage storage none bind,create=dir
EOF



exit 0
