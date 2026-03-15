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

    ssl_certificate /etc/letsencrypt/live/alexlupu.dev/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/alexlupu.dev/privkey.pem;

    root {{WEB_ROOT}};
    index index.html index.htm index.php;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location {{API_LOCATION}} {
        proxy_pass http://127.0.0.1:{{API_PORT}}/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /uploads/ {
        alias {{UPLOADS_DIR}}/;
        access_log off;
        expires 1h;
    }
}
