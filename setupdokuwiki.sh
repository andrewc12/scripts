Insert in /etc/nginx/sites-enabled/default
server {
       listen 80;
       listen [::]:80;

       root /var/www/example.com;
       index index.html;

       server_name dokuwiki.innestech.net;
    # serve static files from nginx
    location ~ ^/dokuwiki/lib/.+\.(css|gif|js|png)$ {
        root /usr/share;
        expires 30d;
    }
    location = /dokuwiki/install.php {
        deny all;
    }
    location = /dokuwiki {
        rewrite ^ /dokuwiki/ permanent;
    }
    location = /dokuwiki/ {
        rewrite ^ /dokuwiki/doku.php last;
        expires 30d;
    }
    location ~ ^/dokuwiki/(|lib/(exe|plugins/[^/]+)/)[^/]+\.php {
        root /usr/share;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        include        fastcgi_params;
    }
    location /dokuwiki/ {
        deny all;
    }
}









that doesn't work






server {
    listen   80;

    root /usr/share/nginx/www;
    index index.php index.html index.htm;

    server_name server_domain_or_IP_address;
    
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

































this works


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













dpkg-reconfigure dokuwiki



















? I installed using the Debian package, but now (for whatever reason, e.g. access to latest release early) I want to go use the DokuWiki download installation (which is not Debian policy compatible) 

(./) Get DokuWiki, install it following the regular instructions. Then restore your old content: 

•Put your old /var/lib/dokuwiki/data content into the data directory of your new DokuWiki installation. 

•You can also try to restore: 
•your configuration file, that are under /etc/dokuwiki; 


•your plugins, that are under /var/lib/dokuwiki/lib/plugins. 


