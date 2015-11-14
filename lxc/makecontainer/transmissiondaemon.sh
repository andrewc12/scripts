#!/bin/sh
CONTAINER=transmission
#Create container
../mkdebianmenu.sh -B none -n $CONTAINER -r jessie 
#In fstab
cat >> /var/lib/lxc/$CONTAINER/fstab << EOF
/storage storage none bind,create=dir
/storage/transmission-daemon var/lib/transmission-daemon none bind,create=dir
EOF


lxc-start -n $CONTAINER -d
#chroot /var/lib/lxc/$container/rootfs/ bin/bash

sleep 20
lxc-attach -n $CONTAINER -- apt-get install transmission-daemon -y

cat > /var/lib/lxc/$CONTAINER/rootfs/lib/systemd/system/transmission-daemon.service << EOF
[Unit]
Description=Transmission BitTorrent Daemon
After=network.target

[Service]
User=debian-transmission
Type=notify
ExecStart=/usr/bin/transmission-daemon -f --log-error
ExecReload=/bin/kill -s HUP $MAINPID

[Install]
WantedBy=multi-user.target
EOF



cat > /var/lib/lxc/$CONTAINER/rootfs/etc/default/transmission-daemon << EOF
# defaults for transmission-daemon
# sourced by /etc/init.d/transmission-daemon

# Change to 0 to disable daemon
ENABLE_DAEMON=1

# This directory stores some runtime information, like torrent files
# and links to the config file, which itself can be found in
# /etc/transmission-daemon/settings.json
CONFIG_DIR="/storage/transmission-daemon/info"

# Default options for daemon, see transmission-daemon(1) for more options
OPTIONS="--config-dir $CONFIG_DIR"

# (optional) extra options to start-stop-daemon
#START_STOP_OPTIONS="--iosched idle --nicelevel 10"
EOF
lxc-stop -n $CONTAINER
exit 0
