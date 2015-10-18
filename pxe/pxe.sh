#!/bin/sh
#13:30 < Riviera> wingman2: needs error handling; you don't check whether apt-get, cd, cp, wget, unzip, mkdir, etc. were successful,
#                 you should quote your expansions ("/msg greybot umq") and, if it doesn't go against your idea of aesthetics, you
#                 should indent your code to improve its readability
#13:34 <greybot> "Double quote" _every_ expansion, and anything that could contain a special character, eg. "$var", "$@",
#                "${array[@]}", "$(command)". Use 'single quotes' to make something literal, eg. 'Costs $5 USD'. See
#                <http://mywiki.wooledge.org/Quotes>, <http://mywiki.wooledge.org/Arguments> and
#                <http://wiki.bash-hackers.org/syntax/words>.
LINES=$(tput lines)
COLUMNS=$(tput cols)

export PXEIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')
DHCPBROADCAST=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $4}')

DHCPDCONF="/etc/dhcp/dhcpd.conf"
#export PXEIP="10.0.0.137"
export TFTPPATH="/srv/tftp"
export PXELINUXMENU="$TFTPPATH/pxelinux.cfg/default"
SYSLINUXPATH="/usr/lib/syslinux"
DHCPSUBNET="10.0.0.0"
DHCPNETMASK="255.255.255.0"
DHCPLEASESTART="10.0.0.10"
DHCPLEASESTOP="10.0.0.20"
#DHCPBROADCAST="10.0.0.255"
DHCPROUTER="10.0.0.3"
DHCPDNS="10.0.0.3"

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
INSTALLPLOP=1
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
installserver(){
apt-get install isc-dhcp-server tftpd-hpa
}


####################MENU####################
while true; do
CHOICE=$(whiptail --title "PXE Setup Menu" --menu "Choose an option" $LINES $COLUMNS $(( $LINES - 8 )) \
"<-- Back" "Return to the main menu." \
"Add User" "Add a user to the system." \
"Modify User" "Modify an existing user." \
"List Users" "List all users on the system." \
"Add Group" "Add a user group to the system." \
"Modify Group" "Modify a group and its list of members." \
"List Groups" "List all groups on the system." 3>&1 1>&2 2>&3)
                                                                        # A trick to swap stdout and stderr.
# Again, you can pack this inside if, but it seems really long for some 80-col terminal users.
exitstatus=$?
if [ $exitstatus = 1 ]; then
    echo "User selected Cancel."
    exit 0
elif [ $exitstatus = 0 ]; then
    echo "User selected " $CHOICE
else
#    echo "User selected Cancel."
    exit 1
fi

echo "(Exit status was $exitstatus)"
done







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
apt-get install syslinux-common pxelinux
#wheezy
cp $SYSLINUXPATH/pxelinux.0 $TFTPPATH/
cp $SYSLINUXPATH/gpxelinux.0 $TFTPPATH/
cp $SYSLINUXPATH/menu.c32 $TFTPPATH/
cp $SYSLINUXPATH/vesamenu.c32 $TFTPPATH/
cp $SYSLINUXPATH/reboot.c32 $TFTPPATH/
cp $SYSLINUXPATH/chain.c32 $TFTPPATH/
cp $SYSLINUXPATH/memdisk $TFTPPATH/
#jessie
cp /usr/lib/PXELINUX/pxelinux.0 $TFTPPATH/
cp /usr/lib/PXELINUX/gpxelinux.0 $TFTPPATH/
cp /usr/lib/syslinux/modules/bios/menu.c32 $TFTPPATH/
cp /usr/lib/syslinux/modules/bios/vesamenu.c32 $TFTPPATH/
cp /usr/lib/syslinux/modules/bios/reboot.c32 $TFTPPATH/
cp /usr/lib/syslinux/modules/bios/chain.c32 $TFTPPATH/
cp /usr/lib/syslinux/modules/bios/ldlinux.c32 $TFTPPATH/
cp /usr/lib/syslinux/modules/bios/libutil.c32 $TFTPPATH/
cp /usr/lib/syslinux/memdisk $TFTPPATH/

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







#https://en.wikibooks.org/wiki/Bash_Shell_Scripting/Whiptail

LINES=$(tput lines)
COLUMNS=$(tput cols)

CHOICE=$(whiptail --title "Menu example" --menu "Choose an option" $LINES $COLUMNS $(( $LINES - 8 )) \
"<-- Back" "Return to the main menu." \
"Add User" "Add a user to the system." \
"Modify User" "Modify an existing user." \
"List Users" "List all users on the system." \
"Add Group" "Add a user group to the system." \
"Modify Group" "Modify a group and its list of members." \
"List Groups" "List all groups on the system." 3>&1 1>&2 2>&3)
                                                                        # A trick to swap stdout and stderr.
# Again, you can pack this inside if, but it seems really long for some 80-col terminal users.
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected " $CHOICE
else
    echo "User selected Cancel."
fi

echo "(Exit status was $exitstatus)"





