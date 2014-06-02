#!/bin/sh
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