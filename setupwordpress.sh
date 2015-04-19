#!/bin/bash
# ---------------------------------------------------------------------------
# setupwordpress.sh - Script to set up wordpress

# Copyright 2015, Andrew Innes <andrew.c12@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.

# Usage: setupwordpress.sh

# Revision history:
# 2015-04-19  Clean up documentation
# 2015-04-18  Clean up documentation
# ????-??-??  first install test
# ????-??-??  changed mysql username and database name
# ????-??-??  Created
# ---------------------------------------------------------------------------

#TODO:

#Based on
#http://theapotek.com/teknotes/2013/11/25/aws-ec2-debian-nginx-wordpress-varnish/

#Step One Install Software
#MySQL
apt-get install mysql-server mysql-client 
#It will ask you to set the root password.

#Nginx
apt-get install nginx 
#Start the nginx service.
/etc/init.d/nginx start 

#PHP & PHP-FPM
#We need to install php, more specifically php-fpm.
apt-get install php5-fpm php5-mysql 

#Step Two Configure nginx & php-fpm
#On debian based distributions, nginx are configured here.
#/etc/nginx/sites-available/
#And are emabled by placing a symbolic link here.
#/etc/nginx/sites-enabled/ 

#Make a backup of the original default configuration.
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak


#Insert this configuration which will serve php pages.
cat > /etc/nginx/sites-available/default << "EOF"
server {
        root /usr/share/nginx/www;
        index index.html index.htm index.php;
        server_name localhost;
        location / {
                try_files $uri $uri/ /index.html;
        }
        location /doc/ {
                alias /usr/share/doc/;
                autoindex on;
                allow 127.0.0.1;
                allow ::1;
                deny all;
        }
        location ~ \.php$ {
               fastcgi_split_path_info ^(.+\.php)(/.+)$;
               fastcgi_pass unix:/var/run/php5-fpm.sock;
               fastcgi_index index.php;
               include fastcgi_params;
        }
}
EOF


#Check to see that PHP-FPM Is using the correct Unix socket.
grep listen /etc/php5/fpm/pool.d/www.conf 
#The result should look like this.
#listen = /var/run/php5-fpm.sock 

#Restart the services to load the configuration changes.
/etc/init.d/php5-fpm restart
/etc/init.d/nginx restart 

#Create a simple PHP page so we can test that the server is configured
#correctly.
cat > /usr/share/nginx/www/info.php  << "EOF"
<?php phpinfo(); ?> 
EOF

#Test your server by heading to http://ip address/info.php

#Once you know that it's working you should delete that page as it displays
#a lot of sensitive information.
rm /usr/share/nginx/www/info.php

#Set up your virtual host.
#Run the following after changing example.org to your domain name.
cat > /etc/nginx/sites-available/example.org  << "EOF"
server {
   listen 80;
   server_name www.example.org example.org;
   root /var/www/example.org/public;
   index index.php index.html;
   location = /favicon.ico {
            log_not_found off;
            access_log off;
   }
   location = /robots.txt {
            allow all;
            log_not_found off;
            access_log off;
   }
   # Deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
   location ~ /\. {
            deny all;
            access_log off;
            log_not_found off;
   }
   location / {
            try_files $uri $uri/ /index.php?$args;
   }
   # Add trailing slash to */wp-admin requests.
   rewrite /wp-admin$ $scheme://$host$uri/ permanent;
   location ~*  \.(jpg|jpeg|png|gif|css|js|ico)$ {
            expires max;
            log_not_found off;
   }
   location ~ \.php$ {
            try_files $uri =404;
            include /etc/nginx/fastcgi_params;
            fastcgi_pass unix:/var/run/php5-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
   }
}
EOF

#Enable the host
#Now enable the host.
cd /etc/nginx/sites-enabled/
ln -s /etc/nginx/sites-available/example.org example.org

#And disable the default configuration.
rm default

#Reload the configuration.
/etc/init.d/nginx reload 

#Create the website root for the virtual host.
mkdir -p /var/www/example.org/public 


#Step Three Install Wordpress
cd /tmp
wget http://wordpress.org/latest.tar.gz
tar xvfz latest.tar.gz
cd wordpress/
mv * /var/www/example.org/public/ 


#Setup the wordpress table and user in mysql.
#wp_database_example_org username example_org password PasswordToChange
#Create the database.
mysqladmin -u root -p create wp_database_example_org

#Add the user.
mysql -u root -p
#Run these commands.
#GRANT ALL PRIVILEGES ON wp_database_example_org.* TO 'example_org'@'localhost' IDENTIFIED BY 'PasswordToChange';
#GRANT ALL PRIVILEGES ON wp_database_example_org.* TO 'example_org'@'localhost.localdomain' IDENTIFIED BY 'PasswordToChange'; FLUSH PRIVILEGES; quit; 
mysql -u root -p -e "GRANT ALL PRIVILEGES ON wp_database_example_org.* TO 'example_org'@'localhost' IDENTIFIED BY 'PasswordToChange'; GRANT ALL PRIVILEGES ON wp_database_example_org.* TO 'example_org'@'localhost.localdomain' IDENTIFIED BY 'PasswordToChange'; FLUSH PRIVILEGES; quit;"

#Change the owner of the root of the virtual host so that the web server
#can write to it.
chown -R www-data:www-data /var/www/example.org/public/ 

#Rename the sample configuration so that it becomes the actual configuration.
mv /var/www/example.org/public/wp-config-sample.php /var/www/example.org/public/wp-config.php 

#Change the table, username and password settings so that they match our actual database.
x="define('DB_NAME', 'database_name_here');"
y="define('DB_NAME', 'myname');"
sed  -i "s/$x/$y/g"   /var/www/example.org/public/wp-config.php

x="define('DB_USER', 'username_here');"
y="define('DB_USER', 'example_org');"
sed  -i "s/$x/$y/g"   /var/www/example.org/public/wp-config.php

x="define('DB_PASSWORD', 'password_here');"
y="define('DB_PASSWORD', 'PasswordToChange');"
sed  -i "s/$x/$y/g"   /var/www/example.org/public/wp-config.php

#nano /var/www/example.org/public/wp-config.php 
#/** The name of the database for WordPress */
#define('DB_NAME', 'wp_database_example_org');
#/** MySQL database username */
#define('DB_USER', 'example_org');
#/** MySQL database password */
#define('DB_PASSWORD', 'PasswordToChange'); 

#Wordpress is now ready to be installed.
#Perform the wordpress configuration by going to.
http://www.example.org/wp-admin/install.php 
