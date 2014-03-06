#!/bin/sh
#13:30 < Riviera> wingman2: needs error handling; you don't check whether apt-get, cd, cp, wget, unzip, mkdir, etc. were successful,
#                 you should quote your expansions ("/msg greybot umq") and, if it doesn't go against your idea of aesthetics, you
#                 should indent your code to improve its readability
#13:30 < Riviera> wingman2: but it doesn't look too bad
#13:34 <greybot> "Double quote" _every_ expansion, and anything that could contain a special character, eg. "$var", "$@",
#                "${array[@]}", "$(command)". Use 'single quotes' to make something literal, eg. 'Costs $5 USD'. See
#                <http://mywiki.wooledge.org/Quotes>, <http://mywiki.wooledge.org/Arguments> and
#                <http://wiki.bash-hackers.org/syntax/words>.
dhcpdconf="/etc/dhcp/dhcpd.conf"
export pxeip="10.0.0.137"
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


installclonezilla=1
installplop=1
installdebianamd64=1
installdebiani386=1
installdebianpreseed=1

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
EOF
fi
#################################################################################################################   


#################################################################################################################   
if [ "$installdebianamd64" -eq 1 ]
then
    cd    
    export debarch="amd64"
    ./installdebian.sh
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
    ./installdebian.sh
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
