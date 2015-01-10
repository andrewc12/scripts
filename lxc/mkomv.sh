#!/bin/bash



#TODO:
#Actually set up reverse SSH tunnel + private sshkey

#rev16 sshkey
#rev15 hostname
#rev13 onthepull
#rev11 yes after omv extra package
#rev10 autossh service
#rev9 sysctl
#rev8 autossh service + Reducing the number of worker threads on the web server
#rev7 omv extras
#rev6 Created symbolic link because boot is on another partition hence there is no boot folder
#rev5 fix fstab
#rev4 use case so that part2 is the same script
#rev1 quote EOF so the heredoc is treated literally


#DRIVE="/dev/sda"
#BOOT="/dev/sda1"
#ROOT="/dev/sda2"
DRIVE="/dev/mmcblk0"
BOOT="/dev/mmcblk0p1"
ROOT="/dev/mmcblk0p2"
TARGET="/target"





function part1 {
fdisk $DRIVE <<EOF
o
n
p
1

+64M
n
p
2


w
EOF

mkfs.ext2 $BOOT
mkfs.f2fs $ROOT

mkdir $TARGET
mount $ROOT $TARGET
mkdir $TARGET/boot
mount $BOOT $TARGET/boot

cd $TARGET
wget --no-check-certificate  https://www.dropbox.com/s/uav4oc6oibmo5mb/Debian-3.17.0-kirkwood-tld-1-rootfs-bodhi.tar.bz2?dl=1

tar -xvf Debian-3.17.0-kirkwood-tld-1-rootfs-bodhi.tar.bz2?dl=1

mount -t proc proc proc/
mount -t sysfs sys sys/
mount -o bind /dev dev/

cp /etc/resolv.conf etc/resolv.conf
cp /home/andrew/mkomv.sh mkomv.sh
chmod +x mkomv.sh
chroot ./ /mkomv.sh part2
exit 0
}



function part2 {


cd /boot
cp -a zImage-3.17.0-kirkwood-tld-1  zImage.fdt
cat dts/kirkwood-pogoplug_v4.dtb  >> zImage.fdt
mkimage -A arm -O linux -T kernel -C none -a 0x00008000 -e 0x00008000 -n Linux-3.17.0-kirkwood-tld-1 -d /boot/zImage.fdt /boot/uImage
mkimage -A arm -O linux -T ramdisk -C gzip -a 0x00000000 -e 0x00000000 -n initramfs-3.17.0-kirkwood-tld-1 -d /boot/initrd.img-3.17.0-kirkwood-tld-1 /boot/uInitrd

passwd

cd /tmp
wget http://ftp.us.debian.org/debian/pool/main/f/f2fs-tools/f2fs-tools_1.4.0-2_armel.deb
#apt-get install  f2fs-tools
dpkg -i f2fs-tools_1.4.0-2_armel.deb


#nano /etc/fstab

#sed -i "s/STRING_TO_REPLACE/STRING_TO_REPLACE_IT/g" /etc/fstab
sed -i "s/ext3/f2fs/g" /etc/fstab
sed -i "s/noatime,errors=remount-ro 0 1/noatime,nodiratime,discard 0 0/g" /etc/fstab
#noatime,nodiratime,discard
#noatime,errors=remount-ro 0 1

#sed -i "s/ext3/f2fs/g" /etc/fstab





cat >> /etc/sysctl.conf <<EOF
vm.laptop_mode=5
vm.dirty_writeback_centisecs=1500
vm.dirty_expire_centisecs=1500
# defaults shown, suggested values of 10 and 1
vm.dirty_ratio = 50
vm.dirty_background_ratio = 10
EOF





cat > /etc/apt/sources.list << EOF
deb http://ftp.us.debian.org/debian/ wheezy main contrib non-free
deb-src http://ftp.us.debian.org/debian/ wheezy main contrib non-free

deb http://security.debian.org/ wheezy/updates main contrib non-free
deb-src http://security.debian.org/ wheezy/updates main contrib non-free

# wheezy-updates, previously known as 'volatile'
deb http://ftp.us.debian.org/debian/ wheezy-updates main contrib non-free
deb-src http://ftp.us.debian.org/debian/ wheezy-updates main contrib non-free
EOF

echo "deb http://packages.openmediavault.org/public kralizec main" > /etc/apt/sources.list.d/openmediavault.list

apt-get update

wget -O - http://packages.openmediavault.org/public/archive.key | apt-key add -

apt-get update

apt-get install openmediavault


wget http://omv-extras.org/openmediavault-omvextrasorg_latest_all.deb
dpkg -i openmediavault-omvextrasorg_latest_all.deb
apt-get install -f -y
apt-get update

#cat > /etc/apt/sources.list.d/omv-extras-org-kralizec.list << EOF
## Regular omv-extras.org repo
#deb http://packages.omv-extras.org/debian/ kralizec main
## Testing omv-extras.org repo
##deb http://packages.omv-extras.org/debian/ kralizec-testing main
## Greyhole repo
##deb http://packages.omv-extras.org/debian/ kralizec-greyhole main
##deb http://www.greyhole.net/releases/deb stable main
## miller repo
#deb http://dh2k.omv-extras.org/debian/ kralizec-miller main
#deb http://ppa.launchpad.net/deluge-team/ppa/ubuntu precise main
## miller testing repo
##deb http://dh2k.omv-extras.org/debian/ kralizec-miller-testing main
## btsync repo
##deb http://packages.omv-extras.org/debian/ kralizec-btsync main
##deb http://debian.yeasoft.net/btsync wheezy main
#EOF
#apt-get update



sed -i "s/worker_processes .;/worker_processes 1;/g" /etc/nginx/nginx.conf
#sed -i "s/pm.max_children = .;/pm.max_children = 1;/g" /etc/php5/fpm/pool.d/openmediavault-webgui.conf
#pm = ondemand
#pm.max_children = 25
sed -i "s/pm.max_children = 25/pm.max_children = 1/g" /etc/php5/fpm/pool.d/openmediavault-webgui.conf
sed -i "s/pm = dynamic/pm = ondemand/g" /etc/php5/fpm/pool.d/www.conf
sed -i "s/pm.max_children = 5/pm.max_children = 1/g" /etc/php5/fpm/pool.d/www.conf
sed -i "s/;pm.process_idle_timeout = 10s;/pm.process_idle_timeout = 10s/g" /etc/php5/fpm/pool.d/www.conf
#;pm.process_idle_timeout = 10s;



apt-get install autossh

#omv-initsystem

cd /boot
cp -a zImage-3.17.0-kirkwood-tld-1  zImage.fdt
cat dts/kirkwood-pogoplug_v4.dtb  >> zImage.fdt
mkimage -A arm -O linux -T kernel -C none -a 0x00008000 -e 0x00008000 -n Linux-3.17.0-kirkwood-tld-1 -d /boot/zImage.fdt /boot/uImage
mkimage -A arm -O linux -T ramdisk -C gzip -a 0x00000000 -e 0x00000000 -n initramfs-3.17.0-kirkwood-tld-1 -d /boot/initrd.img-3.17.0-kirkwood-tld-1 /boot/uInitrd

ln -s . boot

#shutdown -r now




cat > /etc/init.d/zram << "EOF"
### BEGIN INIT INFO
# Provides:          zram
# Required-Start:    $local_fs
# Required-Stop:     $local_fs
# Default-Start:     S
# Default-Stop:      0 1 6
# Short-Description: Use compressed RAM as in-memory swap
# Description:       Use compressed RAM as in-memory swap
### END INIT INFO

SIZE=32
RESERVE=32
case "$1" in
  "start")
    for i in $(cat /proc/meminfo |grep 'MemAvailable:' | cut -f2 -d ':' | sed 's/ //g' |sed 's/.B//g')
    do
    SIZE=$(((i - (RESERVE*1024))*1024))
    done

    modprobe zram num_devices=1

#    echo $(($SIZE*1024*1024)) > /sys/block/zram0/disksize
    echo $SIZE > /sys/block/zram0/disksize
    mkswap /dev/zram0
    swapon /dev/zram0 -p 10
    ;;
  "stop")
    swapoff /dev/zram0
    modprobe -r zram
    ;;
  *)
    echo "Usage: `basename $0` (start | stop)"
    exit 1
    ;;
esac
EOF
chmod +x /etc/init.d/zram
insserv zram

cat > /etc/init.d/onthepull << "EOF"
### BEGIN INIT INFO
# Provides:          onthepull
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs $network
# Default-Start:     S
# Default-Stop:      0 1 6
# Short-Description: Download and run script file from the internet
# Description:       Download and run script file from the internet
### END INIT INFO

MACADDR="$(cat /sys/class/net/eth0/address | sed 's/://g')"
HOST="http://www.innestech.net/onthepull"
FILE="onthepull.sh"
HASH="onthepull.md5"
case "$1" in
  "start")
cd /tmp
rm $FILE $HASH
wget $HOST/$MACADDR/$FILE > $FILE
wget $HOST/$MACADDR/$HASH > $HASH
md5sum -c $HASH || exit 1
chmod +x $FILE
./$FILE &
exit 0
;;
  "stop")
  exit 0
    ;;
  *)
    echo "Usage: `basename $0` (start | stop)"
    exit 1
    ;;
esac
EOF
#chmod +x /etc/init.d/onthepull
#insserv onthepull



cat > /etc/init.d/autosshd << "EOF"
#! /bin/sh
### BEGIN INIT INFO
# Provides:          autosshd
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: autosshd initscript
# Description:       This file should be used to construct scripts to be
#                    placed in /etc/init.d.
### END INIT INFO

#
# autosshd This script starts and stops the autossh daemon
#
# chkconfig: 2345 95 15
# processname: autosshd
# description: autosshd is the autossh daemon.

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

# Check that networking is up.
#[ ${NETWORKING} = "no" ] && exit 0

PATH=/sbin:/usr/sbin:/bin:/usr/bin
NAME=autossh
DAEMON=/usr/bin/$NAME
TUNNEL_HOST="your public ssh server"
TUNNEL_PORT=90022
DAEMON_ARGS=" -M 0 -f -nNT -i PATH_TO_YOUR/id_rsa -R $TUNNEL_PORT:localhost:22 $TUNNEL_HOST"
DESC="autossh for reverse ssh"
PIDFILE=/var/run/$NAME.pid
export AUTOSSH_PIDFILE=$PIDFILE
SCRIPTNAME=/etc/init.d/$NAME

#
# Function that starts the daemon/service
#
do_start()
{
	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   2 if daemon could not be started
	start-stop-daemon --start --quiet --exec $DAEMON --test > /dev/null \
		|| return 1
	start-stop-daemon --start --quiet --exec $DAEMON -- \
		$DAEMON_ARGS \
		|| return 2
	# Add code here, if necessary, that waits for the process to be ready
	# to handle requests from services started subsequently which depend
	# on this one.  As a last resort, sleep for some time.
}

#
# Function that stops the daemon/service
#
do_stop()
{
	# Return
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   2 if daemon could not be stopped
	#   other if a failure occurred
	start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --name $NAME
	RETVAL="$?"
	[ "$RETVAL" = 2 ] && return 2
	# Wait for children to finish too if this is a daemon that forks
	# and if the daemon is only ever run from this initscript.
	# If the above conditions are not satisfied then add some other code
	# that waits for the process to drop all resources that could be
	# needed by services started subsequently.  A last resort is to
	# sleep for some time.
	start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
	[ "$?" = 2 ] && return 2
	# Many daemons don't delete their pidfiles when they exit.
	rm -f $PIDFILE
	return "$RETVAL"
}


#
# Function that sends a SIGHUP to the daemon/service
#
case "$1" in
  start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
  status)
	status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
	;;
  *)
	echo "Usage: $SCRIPTNAME {start|stop|status|restart}" >&2
	exit 3
	;;
esac
EOF
#chmod +x /etc/init.d/autosshd
#insserv autosshd


cat > /etc/hostname << EOF
openmediavault
EOF
cat > /etc/hosts << EOF
# This configuration file is auto-generated.
# WARNING: Do not edit this file, your changes will be lost.
127.0.0.1 localhost
127.0.1.1 openmediavault

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF




cd /root
mkdir --mode=700 .ssh
cat >> .ssh/authorized_keys << "PUBLIC_KEY"
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAiP0arxywVo1ZRtgb3cyKxwDtVBREsyYO2pIU5Qwb6/MCU1js0Q3U7vW0XfL4j1/BlJu83QHyvbCpt7XZW6THWcNUuNHBJLpZE/1nU5Z+kOcxFpX6M6ZB43/gLsZDU6ZV4qBmDW7FcBv4PUWQkIH1iQUCaJS6mhRpc9BdSDYaaisdurQkwzE5iEOGZJ4V6MoHSoskMilxe6rhkZpt5ZJ868YSNngT2i06ECkZizj7zDswWx9NezTBDrntFOqxjIUznvwcnAUVv9Q2Qvj1YMhjY1Mca6fKdqr8dea5VIyDItN4G4wShQ7J/4dupzrbeXhaKgsnnwNR32OWBTbgUW+8nTCbwOr5yi0BqQSCpVSKvGo4dee2/Ywt4eecU9VE1DE8+5hyCCPUtcWsBUhfU5o5eW4FyUr8rh6AkbzDR/YxrUzhO0JAtqe+mwQEIxwbkxkQhaz+w0lC/m97JMCjt2PeswLDq8YjkmT8NyEvyd573ukSBBP276fbOkMkvW/enpRTIyMbxQUHh5gI2yBcC8gSx1wXPihtJrl4KT65fRDKZovkAAr39Fsyeje/Zv2/Nh6YHnU2D6SpNKDa4wBk1aTy4ZTXuI7yfqsfnQS/TM+I/wj5fy+yRx6JNfVwb/9s/9nNYXpaKSwbQzD6trqpVSl/3edb/U9c7RxbELRqBvWNl1M= andrew it03
PUBLIC_KEY
chmod 600 .ssh/authorized_keys
restorecon -R .ssh

exit 0
}




case "$1" in
  "part1")
    part1
    ;;
  "part2")
    part2
    ;;
  *)
    echo "Usage: `basename $0` (part1 | part2)"
    exit 1
    ;;
esac




#gah something about changing php5-fpm pool to on demand