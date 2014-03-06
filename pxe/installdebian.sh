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
EOF