#!/bin/bash
apt-get install dokuwiki
cat > /etc/nginx/sites-available/dokuwiki << EOF
server {
    listen   80;

    root /usr/share/dokuwiki;
    index index.php index.html index.htm;

    server_name 	dokuwiki.innestech.net;
    
    location / {
        try_files $uri $uri/ /index.html;
    }

    error_page 404 /404.html;

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/www;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    location ~ /(data|conf|bin|inc)/ {
        deny all;
    }
}
EOF

ln -s /etc/nginx/sites-available/dokuwiki /etc/nginx/sites-enabled/dokuwiki

sudo service nginx restart
