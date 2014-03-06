#!/bin/sh
    cat >> $pxelinuxmenu << EOF
LABEL DIamd64preseed
MENU LABEL Install debian amd64 preseed
        kernel debian-installer/amd64/linux
        append vga=normal initrd=debian-installer/amd64/initrd.gz auto=true interface=auto netcfg/dhcp_timeout=60 netcfg/choose_interface=auto priority=critical preseed/url=tftp://$pxeip/debian-installer/preseed.cfg DEBCONF_DEBUG=5
#        IPAPPEND 2
EOF