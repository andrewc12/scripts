#!/bin/bash
# ---------------------------------------------------------------------------
# actwelve - Library functions for various uses

# Copyright 2015, Andrew Innes <andrew.c12@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.

# Usage: new_script [-h|--help] [-q|--quiet] [-s|--root] [script]

# Revision history:
# 2015-04-12  Created
# ---------------------------------------------------------------------------

function f_actwelve_chooseDebianRelease {
local  __resultvar=$1
local DIALOG=${DIALOG=dialog}
local tempfile=`tempfile 2>/dev/null` || exit 1
trap "rm -f $tempfile" 0 1 2 5 15
# Debian release selection 
$DIALOG --clear --title "Debian Release" \
        --menu "Choose the Debian Release:" 20 51 4 \
        "jessie"  "Debian 8 Jessie" \
        "wheezy"  "Debian 7 Wheezy" 2> $tempfile
retval=$?
local myresult=`cat $tempfile`
if [[ "$__resultvar" ]]; then
    eval $__resultvar="'$myresult'"
else
    echo "$myresult"
fi
return $retval
}


function f_actwelve_chooseLxcBackingStore {
local  __resultvar=$1
local DIALOG=${DIALOG=dialog}
local tempfile=`tempfile 2>/dev/null` || exit 1
trap "rm -f $tempfile" 0 1 2 5 15
# Backing store selection
$DIALOG --clear --title "Backing Store" \
        --menu "Choose the Backing store:" 20 51 4 \
        "dir"  "A directory" \
        "none"  "A directory" \
        "loop"  "A file backed loop device" 2> $tempfile
retval=$?
local myresult=`cat $tempfile`
if [[ "$__resultvar" ]]; then
    eval $__resultvar="'$myresult'"
else
    echo "$myresult"
fi
return $retval
}


function f_actwelve_chooseLxcName {
local  __resultvar=$1
local DIALOG=${DIALOG=dialog}
local tempfile=`tempfile 2>/dev/null` || exit 1
trap "rm -f $tempfile" 0 1 2 5 15
# Container name  selection
$DIALOG --title "Container Name" --clear \
        --inputbox "Choose a name for your container:" 16 51 2> $tempfile
retval=$?
local myresult=`cat $tempfile`
if [[ "$__resultvar" ]]; then
    eval $__resultvar="'$myresult'"
else
    echo "$myresult"
fi
return $retval
}

function f_actwelve_inputIpAddress {
local  __resultvar=$1
local DIALOG=${DIALOG=dialog}
local tempfile=`tempfile 2>/dev/null` || exit 1
trap "rm -f $tempfile" 0 1 2 5 15
# Input IP address
$DIALOG --title "IP address" --clear \
        --inputbox "Enter IP address:" 16 51 2> $tempfile
retval=$?
local myresult=`cat $tempfile`
if [[ "$__resultvar" ]]; then
    eval $__resultvar="'$myresult'"
else
    echo "$myresult"
fi
return $retval
}


function f_actwelve_chooseRamSizeMB {
local  __resultvar=$1
local DIALOG=${DIALOG=dialog}
local tempfile=`tempfile 2>/dev/null` || exit 1
trap "rm -f $tempfile" 0 1 2 5 15
# Debian release selection 
$DIALOG --clear --title "RAM Size" \
        --menu "Choose the RAM Size:" 20 51 16 \
        "1"    "1MB"    \
        "2"    "2MB"    \
        "4"    "4MB"    \
        "8"    "8MB"    \
        "16"    "16MB"    \
        "32"    "32MB"    \
        "64"    "64MB"    \
        "128"    "128MB"    \
        "256"    "256MB"    \
        "512"    "512MB"    \
        "1024"    "1024MB"    \
        "2048"    "2048MB"    \
        "4096"    "4096MB"    \
        "8192"    "8192MB"    \
        "16384"    "16384MB"    \
        "32768"    "32768MB" 2> $tempfile
retval=$?
local myresult=`cat $tempfile`
if [[ "$__resultvar" ]]; then
    eval $__resultvar="'$myresult'"
else
    echo "$myresult"
fi
return $retval
}








return 0
#!/bin/sh
    mkdir /tmp/di$debarch
    cd /tmp/di$debarch
    wget -c ftp://ftp.debian.org/debian/dists/wheezy/main/installer-$debarch/current/images/netboot/netboot.tar.gz
    tar -xvf netboot.tar.gz
    mkdir -p $tftppath/debian-installer/
    mv debian-installer/$debarch $tftppath/debian-installer/.
    cat >> $pxelinuxmenu << EOF
MENU BEGIN DI$debarch
MENU LABEL Install debian $debarch
MENU TITLE Install debian $debarch
LABEL Back
MENU EXIT
MENU LABEL Back
MENU INCLUDE debian-installer/$debarch/boot-screens/menu.cfg
MENU END
EOF#!/bin/sh
    cat >> $pxelinuxmenu << EOF
LABEL preseedDI$debarch
MENU LABEL Install debian $debarch preseed
        kernel debian-installer/$debarch/linux
        append vga=normal initrd=debian-installer/$debarch/initrd.gz auto=true interface=auto netcfg/dhcp_timeout=60 netcfg/choose_interface=auto priority=critical preseed/url=tftp://$pxeip/debian-installer/preseed.cfg DEBCONF_DEBUG=5
#        IPAPPEND 2
EOF#!/bin/sh
    cd /tmp
    wget -c  http://download.plop.at/files/bootmngr/plpbt-5.0.15-test.zip
    unzip plpbt-5.0.15-test.zip
    mv plpbt-5.0.15-test $tftppath/images/plop
    cat >> $pxelinuxmenu << EOF
MENU BEGIN Plop
MENU LABEL Plop
MENU TITLE Plop boot loader
LABEL Back
MENU EXIT
MENU LABEL Back
LABEL Plop Live
kernel images/plop/plpbt.bin
MENU LABEL Plop
TEXT HELP
Run Plop
ENDTEXT
LABEL Plop Install
kernel images/plop/install/plpinstc.com
MENU LABEL Install Plop
TEXT HELP
Run Plop Install
ENDTEXT
MENU END
EOF#!/bin/sh
#13:30 < Riviera> wingman2: needs error handling; you don't check whether apt-get, cd, cp, wget, unzip, mkdir, etc. were successful,
#                 you should quote your expansions ("/msg greybot umq") and, if it doesn't go against your idea of aesthetics, you
#                 should indent your code to improve its readability
#13:34 <greybot> "Double quote" _every_ expansion, and anything that could contain a special character, eg. "$var", "$@",
#                "${array[@]}", "$(command)". Use 'single quotes' to make something literal, eg. 'Costs $5 USD'. See
#                <http://mywiki.wooledge.org/Quotes>, <http://mywiki.wooledge.org/Arguments> and
#                <http://wiki.bash-hackers.org/syntax/words>.

export PXEIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
DHCPBROADCAST=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $4}')

DHCPDCONF="/etc/dhcp/dhcpd.conf"
#export PXEIP="10.0.0.137"
export TFTPPATH="/srv/tftp"
export PXELINUXMENU="$TFTPPATH/pxelinux.cfg/default"
SYSLINUXPATH="/usr/lib/syslinux"
DHCPSUBNET="10.0.0.0"
DHCPNETMASK="255.255.255.0"
DHCPLEASESTART="10.0.0.180"
DHCPLEASESTOP="10.0.0.200"
#DHCPBROADCAST="10.0.0.255"
DHCPROUTER="10.0.0.138"
DHCPDNS="10.0.0.138"

#Enter the Mac address of the computers you want to boot
#or comment out ignore unknown-clients; below
PXEMAC1="08:00:27:F4:1E:9C"
PXEMAC2="08:00:27:F4:1E:9C"
PXEMAC3="08:00:27:F4:1E:9C"
PXEMAC4="08:00:27:F4:1E:9C"

#URL='http://login:password@example.com/one/more/dir/file.exe?a=sth&b=sth'
#AFTER_SLASH=${URL##*/}
#echo "/one/more/dir/${AFTER_SLASH%%\?*}"
#http://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.2.1-25/clonezilla-live-2.2.1-25-i686-pae.zip

#FILE=/home/user/src/prog.c
#echo ${FILE#/*/}  # ==> user/src/prog.c
#echo ${FILE##/*/} # ==> prog.c
#echo ${FILE%/*}   # ==> /home/user/src
#echo ${FILE%%/*}  # ==> nil
#echo ${FILE%.c}   # ==> /home/user/src/prog

#done test
#fix this with regex
CZPAEURL="http://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.2.1-25/clonezilla-live-2.2.1-25-i686-pae.zip"

INSTALLCLONEZILLA=0
INSTALLPLOP=0
INSTALLDEBIANAMD64=1
INSTALLDEBIANI386=0
INSTALLDEBIANPRESEED=1

# http://linuxcommand.org/wss0150.php
#PROGNAME=$(basename $0)
#function error_exit
#{
#	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
#	exit 1
#}
# Example call of the error_exit function.  Note the inclusion
# of the LINENO environment variable.  It contains the current
# line number.
# error handling
# Simplest of all
#echo "Example of error with line number and message"
#cd $some_directory || error_exit "$LINENO: Cannot change directory! Aborting"
#rm *

installdebian(){
    mkdir /tmp/di${DEBARCH}
    cd /tmp/di${DEBARCH}
    wget -c ftp://ftp.debian.org/debian/dists/wheezy/main/installer-${DEBARCH}/current/images/netboot/netboot.tar.gz
    tar -xvf netboot.tar.gz
    mkdir -p $TFTPPATH/debian-installer/
    mv debian-installer/${DEBARCH} $TFTPPATH/debian-installer/.
    cat >> $PXELINUXMENU << EOF
MENU BEGIN DI${DEBARCH}
MENU LABEL Install debian ${DEBARCH}
MENU TITLE Install debian ${DEBARCH}
LABEL Back
MENU EXIT
MENU LABEL Back
MENU INCLUDE debian-installer/${DEBARCH}/boot-screens/menu.cfg
MENU END
EOF
}

installdebianpreseed(){
    cat >> $PXELINUXMENU << EOF
LABEL preseedDI${DEBARCH}
MENU LABEL Install debian ${DEBARCH} preseed
	kernel debian-installer/${DEBARCH}/linux
	append vga=normal initrd=debian-installer/${DEBARCH}/initrd.gz auto=true interface=auto netcfg/dhcp_timeout=60 netcfg/choose_interface=auto priority=critical preseed/url=tftp://$PXEIP/debian-installer/preseed.cfg DEBCONF_DEBUG=5
EOF
}

apt-get install isc-dhcp-server tftpd-hpa

cat > $DHCPDCONF << EOF

default-lease-time 600;
max-lease-time 7200;
allow booting;
#ignore unknown-clients;
subnet $DHCPSUBNET netmask $DHCPNETMASK {
    range $DHCPLEASESTART $DHCPLEASESTOP;
    option broadcast-address $DHCPBROADCAST;
    option routers $DHCPROUTER;
    option domain-name-servers $DHCPDNS;
    next-server $PXEIP;
}

#chainloading
if exists user-class and option user-class = "gPXE" {
    filename "pxelinux.0";
} else {
    if substring(option vendor-class-identifier, 0, 9) = "PXEClient" {
        filename "gpxelinux.0";
    }
}
#Find out if this works 
#if substring(option vendor-class-identifier, 0, 9) = "PXEClient" {filename "gpxelinux.0";}
#if exists user-class and option user-class = "gPXE" {filename "pxelinux.0";}
host 1 { hardware ethernet $PXEMAC1; }
host 2 { hardware ethernet $PXEMAC2; }
host 3 { hardware ethernet $PXEMAC3; }
host 4 { hardware ethernet $PXEMAC4; }

EOF
/etc/init.d/isc-dhcp-server restart

#In this section we set up a menu to load and boot files from the network
#Files to boot
mkdir $TFTPPATH/
mkdir $TFTPPATH/images
mkdir $TFTPPATH/pxelinux.cfg
#Copy syslinux files
apt-get install syslinux
cp $SYSLINUXPATH/pxelinux.0 $TFTPPATH/
cp $SYSLINUXPATH/gpxelinux.0 $TFTPPATH/
cp $SYSLINUXPATH/menu.c32 $TFTPPATH/
cp $SYSLINUXPATH/vesamenu.c32 $TFTPPATH/
cp $SYSLINUXPATH/reboot.c32 $TFTPPATH/
cp $SYSLINUXPATH/chain.c32 $TFTPPATH/
cp $SYSLINUXPATH/memdisk $TFTPPATH/

cat > $PXELINUXMENU << EOF
ui menu.c32
menu title Utilities
EOF

##############################################################################################################
if [ "$INSTALLCLONEZILLA" -eq 1 ]
then
    #Extract the latest version
    mkdir /tmp/clonezilla
    cd /tmp
    wget -c $CZPAEURL #http://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.2.1-25/clonezilla-live-2.2.1-25-i686-pae.zip
    cd /tmp/clonezilla
    unzip ../${CZPAEURL##*/} #clonezilla-live-2.2.1-25-i686-pae.zip
    cd ..
    mv clonezilla $TFTPPATH/images/clonezilla
    cat >> $PXELINUXMENU << EOF
label clonezilla
menu label Clonezilla
  kernel images/clonezilla/live/vmlinuz
  append boot=live username=user config  noswap edd=on nomodeset noprompt locales= keyboard-layouts= ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_batch=no vga=788 nosplash fetch=tftp://$PXEIP/images/clonezilla/live/filesystem.squashfs i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=no
  initrd images/clonezilla/live/initrd.img
EOF
fi
#################################################################################################################   
if [ "$INSTALLPLOP" -eq 1 ]
then
    cd /tmp
    wget -c  http://download.plop.at/files/bootmngr/plpbt-5.0.15-test.zip
    unzip plpbt-5.0.15-test.zip
    mv plpbt-5.0.15-test $TFTPPATH/images/plop
    cat >> $PXELINUXMENU << EOF
MENU BEGIN Plop
MENU LABEL Plop
MENU TITLE Plop boot loader
LABEL Back
MENU EXIT
MENU LABEL Back
LABEL Plop Live
kernel images/plop/plpbt.bin
MENU LABEL Plop
TEXT HELP
Run Plop
ENDTEXT
LABEL Plop Install
kernel images/plop/install/plpinstc.com
MENU LABEL Install Plop
TEXT HELP
Run Plop Install
ENDTEXT
MENU END
EOF

fi
##############################################################################################################
if [ "$INSTALLDEBIANAMD64" -eq 1 ]
then
    export DEBARCH="amd64"
    installdebian
    if [ "$INSTALLDEBIANPRESEED" -eq 1 ]
    then
        installdebianpreseed
    fi
fi
##############################################################################################################
if [ "$INSTALLDEBIANI386" -eq 1 ]
then
    export DEBARCH="i386"
    installdebian
    if [ "$INSTALLDEBIANPRESEED" -eq 1 ]
    then
        installdebianpreseed
    fi
fi
##############################################################################################################








#cd /tmp
#wget -c http://mirrors.xbmc.org/releases/XBMCbuntu/xbmcbuntu-13.0~gotham_amd64.iso
#mkdir /mnt/iso
#mount -o loop xbmcbuntu-13.0~gotham_amd64.iso /mnt/iso
#mkdir /tmp/xbmcbuntu-13.0~gotham_amd64
#cp -R /mnt/iso/* /tmp/xbmcbuntu-13.0~gotham_amd64
#umount /mnt/iso
#mv xbmcbuntu-13.0~gotham_amd64 /srv/tftp/images/.



#apt-get install nfs-kernel-server

#    /etc/exports
#
#    /srv/tftp/images/xbmcbuntu-13.0~gotham_amd64       10.0.0.0/255.255.255.0(async,no_root_squash,no_subtree_check,ro)
#
#service nfs-kernel-server restart
#
#label xbmc
#  menu label ^Try XBMCbuntu without installing
#  kernel images/xbmcbuntu-13.0~gotham_amd64/casper/vmlinuz
#  append  boot=casper netboot=nfs nfsroot=10.0.0.191:/srv/tftp/images/xbmcbuntu-13.0~gotham_amd64/ initrd=images/xbmcbuntu-13.0~gotham_amd64/casper/initrd.lz --

# label bootlocal
#      menu label ^Boot Point of Sale
#      menu default
#      localboot 0
#      timeout 80
#      TOTALTIMEOUT 9000









/etc/init.d/tftpd-hpa restart
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




#gah something about changing php5-fpm pool to on demand#!/bin/bash

container=$1
mkdir /var/lib/lxc/$container
touch /var/lib/lxc/$container/rootdev
SUITE=wheezy lxc-create -B loop --fstype ext4 -n $container -t debian -o log -- -r jessie
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

echo "lxc.network.hwaddr = $macaddr" >> /var/lib/lxc/$container/config
echo "lxc.network.hwaddr = $macaddr"


lxc-start -n $container -d
#chroot /var/lib/lxc/$container/rootfs/ bin/bash

sleep 20
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









#truncate -s8G /var/lib/lxc/$container/rootdev
#e2fsck -f /var/lib/lxc/$container/rootdev && resize2fs /var/lib/lxc/$container/rootdev



#!/bin/bash
#add to path
#C:\Program Files\Oracle\VirtualBox

vbName="zentyal"
vbHdSize="7500"
vbHdName="F:/vm/$vbName/$vbName"
vbIsoName="C:\Users\andre_000\Downloads\openmediavault_1.9_amd64.iso"

#F:\vm
#HowOpenSource
#Home»Linux» How to use VirtualBox in Terminal / Command line
#How to use VirtualBox in Terminal / Command line
#Updated by Administrator | Apr 23, 2013 | Linux | 2 Comments
#PART ONE
#Advertisements
#How to manage VirtualBox in command line or terminal. VBoxManage is the command which is used to manage VirtualBox in commandline. Using VBoxManage, one can create and control the virtual OS and there are many features than GUI VirtualBox.
#Here is a simple tutorial on how to create a virtual OS (Ubuntu10.10) using VBoxManage and access it remotely from the host machine.
#
#Advertisements
#INTRUCTIONS
#To create a virtualmachine(Ubuntu10.10), use the below command or copy and paste it in terminal. If you want to create a virtual machine for fedora or some other OS, change the name Ubuntu10.10 to fedora or slax or kubuntu etc.
#VBoxManage createvm --name Ubuntu10.10
#In the above command, “createvm” is used to create a virtual machine and “–name“defines the name of the virtual machine. After executing this command it will create virtual machine called “Ubuntu10.10.vbox” in home folder under “VirtualBox VMs/Ubuntu10.10/Ubuntu10.10.vbox”
#*Note: If the name has space, then it should be given within quotes.
#Say for example, “Ubuntu 10.10?.
#Now, create the hard disk image for the virtual machine using the below command
#In the above command, “createhd” is used to create hard disk image and “–filename” is used to specify the virtual machine’s name, for which the hard disk image is created. Here, “–size” denotes the size of the hard disk image. The size is always given in MB. Here we have specified 5Gb that is 5120MB.
#After creating a virtual machine, the VirtualBox has to be registered. “registervm” command is used to register the virtual machine. The full path of the virtual machine’s location has to be mentioned.
#VBoxManage registervm '/home/user/VirtualBox VMs/Ubuntu10.10/Ubuntu10.10.vbox'
#or
#The virtualmachine can be registered while creating virtual machine using “–register“. Below is the command
VBoxManage createvm --name $vbName --register

#"Settings file: 'F:\vm\Ubuntu10.10\Ubuntu10.10.vbox'"

VBoxManage createhd --filename "$vbHdName" --size $vbHdSize
#VBoxManage createhd --filename Ubuntu10.10 --size 5120

#Now set the OS type. For example, if the Linux OS has to be installed, then specify the OS type as Linux or Ubuntu Or Fedora etc.
VBoxManage modifyvm $vbName --ostype Debian
#One of the most important command in VBoxManage is “modifyvm“. Using “modifyvm”, one can modify many features in virtual machine like changing the memory size, name of the Virtual Machine, OS type and many more. The name of the virtual machine has to be specified inorder to modify it. In the above command, Ubuntu10.10 has been explained. The command “–ostype” is used to set the OS type like Linux, Windows, Ubuntu, Fedora, etc,.
#Now, set the memory size for the virtual OS, i.e. the ram size for the virtual OS from the host Machine.
VBoxManage modifyvm $vbName --memory 512
#The command “–memory <size>” is used to set the RAM size for the virtual machine from the host machine. The size should be defined in MB.
#Now create a storage controller for the virtual machine.
VBoxManage storagectl $vbName --name IDE --add ide --controller PIIX4 --bootable on
#“storagectl <name>” is used to create a storage controller for virtual machine. Later the virtual media can be attached to the controller using “storageattach” command. The above command creates the storage controller called IDE. <name> defines the name of the virtual machine.
#Here,
#“–name <name>” specifies the name of the storage controller that needs to be created or modified or removed from the virtual machine.
#“–add <options>” defines the type of system bus to which the storage controller must be connected. Available options are ide/sata/scsi/floppy.
#“–controller <options>” allows to choose the type of chipset that is to be emulated for the given storage controller. Available options are LsiLogic / LSILogicSAS / BusLogic / IntelAhci / PIIX3 / PIIX4 / ICH6 / I82078.
#“–bootable <on/off>” defines whether this controller is bootable or not.
VBoxManage storagectl $vbName --name SATA --add sata --controller IntelAhci --bootable on
#Using the above command, a storage controller called SATA has been created. The hard disk image can be attached to this later.
#Now, attach the storage controller to the virtual machine using “storageattach” .
VBoxManage storageattach $vbName --storagectl SATA --port 0 --device 0 --type hdd --medium "$vbHdName.vdi"
#The above command will attach the storage controller SATA to virtual machine Ubuntu10.10 with the medium i.e., to the virtual disk image which is created.
#“storageattach <name>” is the command used to attach the storage controller to the virtual machine.
#<name> defines the name of the virtual machine.
#“–storagectl <name>” is used to define the name of the storage controller which needs to be attached to the virtual machine.
#<name> defines the name of the storage controller.
#“–port <number>” is used to define the number of storage controller’s port which is to be modified.
#“–device <number>” is used to define the number of the port’s device which is to be modified.
#“–type <options>” is used to specify the type of the drive in which the medium should be attached. Available options are dvddrive / hdd / fdd.
#“–medium <options>” defines the hard disk image or ISO image file or virtual DVD. Available options are none / emptydrive / <uuid> / <filename>host:<drive>iscsi
#*Note: If you decide to specify the filename, then specify the full path where it is located.
#Example: “/home/user/Ubuntu10.10.vdi”
VBoxManage storageattach $vbName --storagectl IDE --port 0 --device 0 --type dvddrive --medium "$vbIsoName"
#Here, the above command will attach the storage controller IDE with the medium of ISO image as DVD drive. This medium can be closed after installing the virtual OS($vbName).
#“filename“– Example: “/home/user/Downloads/ubuntu-10.10-desktop-i386.iso”
#Next, add some features like audio, 3d acceleration, network, etc,.
#VBoxManage modifyvm $vbName --vram 128 --accelerate3d on --audio alsa --audiocontroller ac97
VBoxManage modifyvm $vbName --vram 8 --audio alsa --audiocontroller ac97
#“–vram <size>” This sets the size of RAM that the virtual graphics card should have. The size should given in MB.
#“–accelerate3d <on/off>” if the guest additions are installed, this sets the hardware 3D acceleration for the virtual machine.
#“–audio <options>” is used to set the audio for the virtual machine with available host driver. Available options are none /null / oss / alsa / pulse.
#“–audiocontroller <options>” is used to set the controller for the audio in the virtual machine. Available options are ac97 / hda / sb16.
#VBoxManage modifyvm $vbName --nic1 nat --nictype1 82540EM --cableconnected1 on
VBoxManage modifyvm $vbName --nic1 bridged --nictype1 virtio --cableconnected1 on
#“–nic<1-N> <options>” with this the type of networking can be set for each of the VM’s virtual network cards. Available options are none / null / nat / bridged / intnet / hostonly / vde.
#“–nictype<1-N> <options>” is used to specify which networking hardware is to be presented to the guest VirtualBox. Available options are Am79C970A / Am79C973 / 82540EM / 82543GC / 82545EM / virtio.
#“–cableconnected<1-N> <on/off>” This allows to temporarily disconnect a virtual network interface from virtual machine. This might be useful for re-setting certain software components in the VM.
#Now to start a virtual machine, use the below command
VBoxManage startvm $vbName
#“startvm <name>” is the command used to start the virtual machine. By default it starts in the GUI mode.
#<name> defines the name of the virtual machine.
#Remote Desktop in VirtualBox
#To activate the remote desktop, set the port number and address.
#VBoxManage modifyvm $vbName --vrde on --vrdeport 5012 --vrdeaddress 192.168.1.6
#“–vrde <on/off>” is used to set the remote desktop ON or OFF.
#“–vrdeport <number>” is used to set the port number in the port in which the virtual machine should be available. “default or 0? will set the port in 3389.
#“–vrdeaddress <address>” is used to set the “IP” address in which it should be accessable.
#Now, start the virtual machine using the below command
#VBoxManage startvm $vbName --type headless
#“–type <options>” is used to specify the mode in which it should start the virtual machine. Available options are gui / sdl / headless.
#“headless” produces no visible output on the host at all, but only delivers VRDP data. This front-end has no dependencies on the X Window system on Linux and Solaris hosts.
#Alternative method to start virtual machine for remote access is VBoxHeadless. Use the below command.
#VBoxHeadless --startvm Ubuntu10.10
#“–startvm <name>” is used to start the virtual machine. <name> defines the name of the virtual machine.
#To access the remote desktop, use rdesktop command. By default the linux system should have rdesktop. If not, install it. Use the below command from the client machine to access the virtual machine remotely.
#rdesktop -a 16 -N 192.168.1.6:5012
#To stop the virtual machine, check the below command
#VBoxManage controlvm $vbName poweroff
#“controlvm <name> <options>” controlvm command is used to control the state of the virtual machine. <name> defines the name of the virtual machine. Some of the available options are pause / resume / reset / poweroff / savestate / acpipowerbutton / acpisleepbutton. There are many options in controlvm to see all the options available in it. Either type or copy and paste the below command in terminal.
#VBoxManage controlvm
#Hope this will be helpful for you!!!
#You might also like:
#Install Virtualbox in Ubuntu 13.04 / 12.10 / 12.04 using PPA
#How to Install OpenERP in Linux
#How to install and manage different versions of Python in ...
#Linkwithin
#Related Posts Plugin for WordPress, Blogger...
#
#Disqus seems to be taking longer than usual. Reload?
#Circle Us on Google+
#
#Advertisement
#HomeAboutPrivacyContact
#Designed by Elegant Themes | Powered by WordPress
