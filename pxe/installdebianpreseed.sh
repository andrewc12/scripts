#!/bin/sh
    cat >> $pxelinuxmenu << EOF
LABEL preseedDI$debarch
MENU LABEL Install debian $debarch preseed
        kernel debian-installer/$debarch/linux
        append vga=normal initrd=debian-installer/$debarch/initrd.gz auto=true interface=auto netcfg/dhcp_timeout=60 netcfg/choose_interface=auto priority=critical preseed/url=tftp://$pxeip/debian-installer/preseed.cfg DEBCONF_DEBUG=5
#        IPAPPEND 2
EOF