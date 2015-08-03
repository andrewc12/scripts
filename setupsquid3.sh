#!/bin/bash
apt-get install squid3 squid3-common


#nano /etc/squid3/squid.conf
#sed -i '/TEXT in line to be replaced/c\new contents' /tmp/foo
#sed 's/.*TEXT_TO_BE_REPLACED.*/This line is removed by the admin./'
sed -i 's!.*acl localnet src 10.0.0.0/8.*!acl localnet src 10.0.0.0/8!' /etc/squid3/squid.conf

sed -i 's!.*http_access allow localhost.*!http_access allow localhost!' /etc/squid3/squid.conf
sed -i 's!.*http_access allow localnet.*!http_access allow localnet!' /etc/squid3/squid.conf


/etc/init.d/squid3 restart
