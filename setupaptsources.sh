#!/bin/bash

#https://wiki.debian.org/DebianGeoMirror

cat > /etc/apt/sources.list << EOF
deb http://httpredir.debian.org/debian jessie main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free
EOF