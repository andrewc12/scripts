#!/bin/sh
CONTAINER=apache
#Create container
../mkdebianmenu.sh -B none -n $CONTAINER -r jessie 
#In fstab


lxc-start -n $CONTAINER -d
#chroot /var/lib/lxc/$container/rootfs/ bin/bash

sleep 20
lxc-attach -n $CONTAINER -- apt-get install apache2 apache2-doc -y
lxc-attach -n $CONTAINER -- apt-get install php5 php5-mysql libapache2-mod-php5 -y
cat > /var/lib/lxc/$CONTAINER/rootfs/tmp/run.sh << EOF
#!/bin/sh
set -x
wget https://github.com/Circa75/dropplets/archive/v1.6.2.6.tar.gz -O /tmp/v1.6.2.6.tar.gz
tar -xvf /tmp/v1.6.2.6.tar.gz -C /tmp/
mv /tmp/dropplets-1.6.2.6/* /var/www/html
rm /var/www/html/index.html
chown -R www-data:www-data /var/www/*
EOF
lxc-attach -n $CONTAINER -- chmod a+x /tmp/run.sh
lxc-attach -n $CONTAINER -- /tmp/run.sh

lxc-stop -n $CONTAINER

cat >> /var/lib/lxc/$CONTAINER/fstab << EOF
/storage storage none bind,create=dir
EOF



exit 0
