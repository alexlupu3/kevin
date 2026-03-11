server {
    listen 80;
    listen [::]:80;
    server_name {{DOMAIN}};

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name {{DOMAIN}};

    root {{WEB_ROOT}};
    index index.php index.html index.htm;

    ssl_certificate {{SSL_CERT}};
    ssl_certificate_key {{SSL_KEY}};

    access_log /var/log/nginx/{{PROJECT}}.access.log;
    error_log /var/log/nginx/{{PROJECT}}.error.log;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:{{PHP_FPM_SOCKET}};
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
