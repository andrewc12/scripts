aptitude install squid3 squid3-common


nano /etc/squid3/squid.conf

acl localnet src 10.0.0.0/24

http_access allow localhost
http_access allow localnet

/etc/init.d/squid3 restart
