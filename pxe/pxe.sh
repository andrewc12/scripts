#!/bin/sh
#13:30 < Riviera> wingman2: needs error handling; you don't check whether apt-get, cd, cp, wget, unzip, mkdir, etc. were successful,
#                 you should quote your expansions ("/msg greybot umq") and, if it doesn't go against your idea of aesthetics, you
#                 should indent your code to improve its readability
#13:34 <greybot> "Double quote" _every_ expansion, and anything that could contain a special character, eg. "$var", "$@",
#                "${array[@]}", "$(command)". Use 'single quotes' to make something literal, eg. 'Costs $5 USD'. See
#                <http://mywiki.wooledge.org/Quotes>, <http://mywiki.wooledge.org/Arguments> and
#                <http://wiki.bash-hackers.org/syntax/words>.
LIST="whiptail unzip wget tput"
for ITEM in `echo $LIST`; do 
command -v $ITEM >/dev/null 2>&1 || { echo >&2 "I require $ITEM but it's not installed.  Aborting."; exit 1; }
done


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

#do_check_dependencies(){
#whiptail, wget, unzip
#}

installdebian(){
    mkdir /tmp/di${DEBARCH}
    cd /tmp/di${DEBARCH}
    wget -c ftp://ftp.debian.org/debian/dists/jessie/main/installer-${DEBARCH}/current/images/netboot/netboot.tar.gz
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
#https://www.debian.org/releases/stable/amd64/apbs04.html.en
cat > $TFTPPATH/debian-installer/preseed.cfg << EOF
d-i debian-installer/language string en
d-i debian-installer/country string US
d-i debian-installer/locale string en_US
d-i console-keymaps-at/keymap select us
d-i keyboard-configuration/xkb-keymap select us

d-i netcfg/get_hostname string unassigned-hostname
d-i netcfg/get_domain string unassigned-domain


# Package mirror
d-i mirror/protocol string http
d-i mirror/country string manual
d-i mirror/http/hostname string ftp.iinet.net.au
d-i mirror/http/directory string /debian/debian
d-i mirror/suite string jessie
 


tasksel tasksel/first multiselect standard, ssh-server
#d-i pkgsel/include string openssh-server























### Partitioning
d-i partman-auto/method string regular
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
#d-i partman-auto/choose_recipe select atomic
#d-i partman/default_filesystem string btrfs

d-i partman-auto/expert_recipe string small-swap : \
        16384 65536 -1 btrfs \
            $primary{ } $bootable{ } \
            method{ format } format{ } \
            use_filesystem{ } filesystem{ btrfs } \
            mountpoint{ / } . \
        1024 4096 50% linux-swap \
            method{ swap } format{ } .

# This makes partman automatically partition without confirmation, provided
# that you told it what to do using one of the methods above.
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true



### Account setup
# Skip creation of a root account (normal user account will be able to
# use sudo).
#d-i passwd/root-login boolean false
# Alternatively, to skip creation of a normal user account.
#d-i passwd/make-user boolean false

# Root password, either in clear text
d-i passwd/root-password password r00tme
d-i passwd/root-password-again password r00tme
# or encrypted using an MD5 hash.
#d-i passwd/root-password-crypted password [MD5 hash]

# To create a normal user account.
d-i passwd/user-fullname string Andrew Innes
d-i passwd/username string andrew
# Normal user's password, either in clear text
d-i passwd/user-password password insecure
d-i passwd/user-password-again password insecure
# or encrypted using an MD5 hash.
#d-i passwd/user-password-crypted password [MD5 hash]
# Create the first user with the specified UID instead of the default.
#d-i passwd/user-uid string 1010

# The user account will be added to some standard initial groups. To
# override that, use this.
#d-i passwd/user-default-groups string audio cdrom video





### Boot loader installation
# Grub is the default boot loader (for x86). If you want lilo installed
# instead, uncomment this:
#d-i grub-installer/skip boolean true
# To also skip installing lilo, and install no bootloader, uncomment this
# too:
#d-i lilo-installer/skip boolean true


# This is fairly safe to set, it makes grub install automatically to the MBR
# if no other operating system is detected on the machine.
d-i grub-installer/only_debian boolean true

# This one makes grub-installer install to the MBR if it also finds some other
# OS, which is less safe as it might not be able to boot that other OS.
d-i grub-installer/with_other_os boolean true

# Due notably to potential USB sticks, the location of the MBR can not be
# determined safely in general, so this needs to be specified:
#d-i grub-installer/bootdev  string /dev/sda
# To install to the first device (assuming it is not a USB stick):
d-i grub-installer/bootdev  string default

# Alternatively, if you want to install to a location other than the mbr,
# uncomment and edit these lines:
#d-i grub-installer/only_debian boolean false
#d-i grub-installer/with_other_os boolean false
#d-i grub-installer/bootdev  string (hd0,1)
# To install grub to multiple disks:
#d-i grub-installer/bootdev  string (hd0,1) (hd1,1) (hd2,1)

# Optional password for grub, either in clear text
#d-i grub-installer/password password r00tme
#d-i grub-installer/password-again password r00tme
# or encrypted using an MD5 hash, see grub-md5-crypt(8).
#d-i grub-installer/password-crypted password [MD5 hash]

# Use the following option to add additional boot parameters for the
# installed system (if supported by the bootloader installer).
# Note: options passed to the installer will be added automatically.
#d-i debian-installer/add-kernel-opts string nousb





popularity-contest popularity-contest/participate boolean false
d-i finish-install/reboot_in_progress note



d-i preseed/late_command string \
in-target wget https://raw.githubusercontent.com/andrewc12/scripts/master/pxe/postinst.sh -O /tmp/postinst.sh; \
in-target /bin/chmod 755 /tmp/postinst.sh; \
in-target /tmp/postinst.sh
EOF


    cat >> $PXELINUXMENU << EOF
LABEL preseedDI${DEBARCH}
MENU LABEL Install debian ${DEBARCH} preseed
	kernel debian-installer/${DEBARCH}/linux
	append vga=normal initrd=debian-installer/${DEBARCH}/initrd.gz auto=true interface=auto netcfg/dhcp_timeout=60 netcfg/choose_interface=auto priority=critical preseed/url=tftp://$PXEIP/debian-installer/preseed.cfg DEBCONF_DEBUG=5
EOF
}
installserver(){
apt-get install isc-dhcp-server tftpd-hpa
apt-get install syslinux
apt-get install syslinux-common pxelinux
#do_copy_syslinux
}


do_copy_syslinux(){
#In this section we set up a menu to load and boot files from the network
#Files to boot
mkdir $TFTPPATH/
mkdir $TFTPPATH/images
mkdir $TFTPPATH/pxelinux.cfg
#Copy syslinux files
#apt-get install syslinux
#apt-get install syslinux-common pxelinux
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
#TODO add this to wheezy
cp /usr/lib/syslinux/modules/bios/libcom32.c32 $TFTPPATH/
}

do_configure_server(){
cat > $DHCPDCONF << EOF
ddns-update-style none;
option domain-name-servers $DHCPDNS;

default-lease-time 600;
max-lease-time 7200;
allow booting;
log-facility local7;

class "pxeclients" {
 match if substring(option vendor-class-identifier, 0, 9) = "PXEClient";
 if exists user-class and option user-class = "gPXE" {
    filename "pxelinux.0";
 } else {
    filename "gpxelinux.0";
 }
}

shared-network 5 {
 subnet $DHCPSUBNET netmask $DHCPNETMASK {
 }
 pool {
  allow members of "pxeclients";
  range $DHCPLEASESTART $DHCPLEASESTOP;
  option broadcast-address $DHCPBROADCAST;
  option routers $DHCPROUTER;
  option domain-name-servers $DHCPDNS;
  next-server $PXEIP;
 }
}
EOF
/etc/init.d/isc-dhcp-server restart
}





do_install_clonezilla(){
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
    echo "User installed clonezilla "
}


do_install_plop(){
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
}



do_install_debian_amd64(){
    export DEBARCH="amd64"
    installdebian
    if [ "$INSTALLDEBIANPRESEED" -eq 1 ]
    then
        installdebianpreseed
    fi
}
##############################################################################################################
do_install_debian_i386(){
    export DEBARCH="i386"
    installdebian
    if [ "$INSTALLDEBIANPRESEED" -eq 1 ]
    then
        installdebianpreseed
    fi
}








do_select_install_payload(){



CHOICE=$(whiptail --title "Payload Selection Menu" --checklist "Choose an option" --separate-output $LINES $COLUMNS $(( $LINES - 8 )) \
"PAYLOAD_PLOP" "Install plop payload" ON \
"PAYLOAD_CLONEZILLA" "Install clonezilla payload" ON \
"PAYLOAD_DEBIAN_PRESEED" "Install debian preseed payloads" ON \
"PAYLOAD_DEBIAN_AMD64" "Install debian amd64 payload" ON \
"PAYLOAD_DEBIAN_I386" "Install debian i386 payload" OFF 3>&1 1>&2 2>&3)
                                                                        # A trick to swap stdout and stderr.
# Again, you can pack this inside if, but it seems really long for some 80-col terminal users.
exitstatus=$?
if [ $exitstatus = 1 ]; then
    echo "User selected Cancel."
    exit 0
elif [ $exitstatus = 0 ]; then
    echo "User selected " $CHOICE
    do_copy_syslinux    
    cat > $PXELINUXMENU << EOF
ui menu.c32
menu title Utilities

LABEL boot_hd0
MENU LABEL Boot from first hard drive
COM32 chain.c32
APPEND hd0
EOF
     for I in $CHOICE; do
         echo "User selected " $I
     case "$I" in
      PAYLOAD_PLOP) do_install_plop ;;
      PAYLOAD_CLONEZILLA) do_install_clonezilla ;;
      PAYLOAD_DEBIAN_PRESEED) INSTALLDEBIANPRESEED=1 ;;
      PAYLOAD_DEBIAN_AMD64) do_install_debian_amd64 ;;
      PAYLOAD_DEBIAN_I386) do_install_debian_i386
     esac
      done
else
#    echo "User selected Cancel."
    exit 1
fi

echo "(Exit status was $exitstatus)"

exit 0





##############################################################################################################


##############################################################################################################

##############################################################################################################
sleep 10
}







































####################MENU####################
while true; do
CHOICE=$(whiptail --title "PXE Setup Menu" --menu "Choose an option" $LINES $COLUMNS $(( $LINES - 8 )) \
"1 Install" "Install the required debian packages." \
"2 Configure" "Configure the services." \
"3 Payloads" "Select download and install the network payloads." \
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
     case "$CHOICE" in
      1\ *) installserver ;;
      2\ *) do_configure_server ;;
      #Install/download software and Generate menus
      3\ *) do_select_install_payload
      #Install/download software and Generate menus
     esac
else
#    echo "User selected Cancel."
    exit 1
fi

echo "(Exit status was $exitstatus)"
done














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
















CHOICE=$(whiptail --title "PXE Setup Menu" --checklist "Choose an option" $LINES $COLUMNS $(( $LINES - 8 )) \
"NET_OUTBOUND" "Allow connections to other hosts" ON \
"NET_INBOUND" "Allow connections from other hosts" OFF \
"LOCAL_MOUNT" "Allow mounting of local devices" OFF \
"REMOTE_MOUNT" "Allow mounting of remote devices" OFF 3>&1 1>&2 2>&3)
                                                                        # A trick to swap stdout and stderr.
# Again, you can pack this inside if, but it seems really long for some 80-col terminal users.
exitstatus=$?
if [ $exitstatus = 1 ]; then
    echo "User selected Cancel."
    exit 0
elif [ $exitstatus = 0 ]; then
    echo "User selected " $CHOICE
     for I in $CHOICE; do
     case "$I" in
      1\ *) installserver ;;
      2\ *) do_configure_server ;;
      #Configure server
      3\ *) do_install_payload
      #Install/download software and Generate menus
      4\ *) do_select_install_payload
      #Install/download software and Generate menus
     done
     esac
else
#    echo "User selected Cancel."
    exit 1
fi

echo "(Exit status was $exitstatus)"






whiptail --title "Menu example" --menu "Choose an option" 20 78 16 \
"<-- Back" "Return to the main menu." \
"Add User" "Add a user to the system." \
"Modify User" "Modify an existing user." \
"List Users" "List all users on the system." \
"Add Group" "Add a user group to the system." \
"Modify Group" "Modify a group and its list of members." \
"List Groups" "List all groups on the system."