#!/bin/sh
#13:30 < Riviera> wingman2: needs error handling; you don't check whether apt-get, cd, cp, wget, unzip, mkdir, etc. were successful,
#                 you should quote your expansions ("/msg greybot umq") and, if it doesn't go against your idea of aesthetics, you
#                 should indent your code to improve its readability
#13:30 < Riviera> wingman2: but it doesn't look too bad
#13:34 <greybot> "Double quote" _every_ expansion, and anything that could contain a special character, eg. "$var", "$@",
#                "${array[@]}", "$(command)". Use 'single quotes' to make something literal, eg. 'Costs $5 USD'. See
#                <http://mywiki.wooledge.org/Quotes>, <http://mywiki.wooledge.org/Arguments> and
#                <http://wiki.bash-hackers.org/syntax/words>.
#


#function e {
#echo $1
#}
#e


export pxeip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/')

dhcpdconf="/etc/dhcp/dhcpd.conf"
#export pxeip="10.0.0.137"
export tftppath="/srv/tftp"
export pxelinuxmenu="$tftppath/pxelinux.cfg/default"
syslinuxpath="/usr/lib/syslinux"
dhcpsubnet="10.0.0.0"
dhcpnetmask="255.255.255.0"
dhcpleasestart="10.0.0.180"
dhcpleasestop="10.0.0.200"
dhcpbroadcast="10.0.0.255"
dhcprouter="10.0.0.138"
dhcpdns="10.0.0.138"

#Enter the Mac address of the computers you want to boot
#or comment out ignore unknown-clients; below
pxemac1="08:00:27:F4:1E:9C"
pxemac2="08:00:27:F4:1E:9C"
pxemac3="08:00:27:F4:1E:9C"
pxemac4="08:00:27:F4:1E:9C"



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
czpaeurl="http://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.2.1-25/clonezilla-live-2.2.1-25-i686-pae.zip"


installclonezilla=0
installplop=0
installdebianamd64=1
installdebiani386=0
installdebianpreseed=0

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


#16:45 < checkbot> wingman2: shellcheck.net says: Line 18: Use
#      <<- instead of << if you want to indent the end token.
#      Line 169: Consider using ( subshell ) or 'cd foo||exit'
#      instead. Line 3: Double quote to prevent globbing and
#      word splitting (and 5 more)

installdebian(){
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
EOF
}



apt-get install isc-dhcp-server tftpd-hpa

cat > $dhcpdconf << EOF

default-lease-time 600;
max-lease-time 7200;
allow booting;
#ignore unknown-clients;
subnet $dhcpsubnet netmask $dhcpnetmask {
    range $dhcpleasestart $dhcpleasestop;
    option broadcast-address $dhcpbroadcast;
    option routers $dhcprouter;
    option domain-name-servers $dhcpdns;
    next-server $pxeip;
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
host 1 { hardware ethernet $pxemac1; }
host 2 { hardware ethernet $pxemac2; }
host 3 { hardware ethernet $pxemac3; }
host 4 { hardware ethernet $pxemac4; }

EOF
/etc/init.d/isc-dhcp-server restart



#In this section we set up a menu to load and boot files from the network
#Files to boot
mkdir $tftppath/
mkdir $tftppath/images
mkdir $tftppath/pxelinux.cfg
#Copy syslinux files
apt-get install syslinux
cp $syslinuxpath/pxelinux.0 $tftppath/
cp $syslinuxpath/gpxelinux.0 $tftppath/
cp $syslinuxpath/menu.c32 $tftppath/
cp $syslinuxpath/vesamenu.c32 $tftppath/
cp $syslinuxpath/reboot.c32 $tftppath/
cp $syslinuxpath/chain.c32 $tftppath/
cp $syslinuxpath/memdisk $tftppath/

cat > $pxelinuxmenu << EOF
ui menu.c32
menu title Utilities
EOF

##############################################################################################################
if [ "$installclonezilla" -eq 1 ]
then
    #Extract the latest version
    mkdir /tmp/clonezilla
    cd /tmp
    wget -c $czpaeurl #http://downloads.sourceforge.net/project/clonezilla/clonezilla_live_stable/2.2.1-25/clonezilla-live-2.2.1-25-i686-pae.zip
    cd /tmp/clonezilla
    unzip ../${czpaeurl##*/} #clonezilla-live-2.2.1-25-i686-pae.zip
    cd ..
    mv clonezilla $tftppath/images/clonezilla
    cat >> $pxelinuxmenu << EOF
label clonezilla
menu label Clonezilla
  kernel images/clonezilla/live/vmlinuz
  append boot=live username=user config  noswap edd=on nomodeset noprompt locales= keyboard-layouts= ocs_live_run="ocs-live-general" ocs_live_extra_param="" ocs_live_batch=no vga=788 nosplash fetch=tftp://$pxeip/images/clonezilla/live/filesystem.squashfs i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=no
  initrd images/clonezilla/live/initrd.img
EOF
fi
##############################################################################################################



#################################################################################################################   
if [ "$installplop" -eq 1 ]
then
    cd
    ./installplop.sh    
fi
#################################################################################################################   


#################################################################################################################   
if [ "$installdebianamd64" -eq 1 ]
then
    cd    
    export debarch="amd64"
    installdebian
    if [ "$installdebianpreseed" -eq 1 ]
    then
        cd
        ./installdebianpreseed.sh    
    fi    
fi        
#################################################################################################################   
    

#################################################################################################################   
if [ "$installdebiani386" -eq 1 ]
then
    cd    
    export debarch="i386"
    installdebian
    if [ "$installdebianpreseed" -eq 1 ]
    then
        cd
        ./installdebianpreseed.sh    
    fi    
fi    
#################################################################################################################   
        

##############################################################################################################

##############################################################################################################

/etc/init.d/tftpd-hpa restart
