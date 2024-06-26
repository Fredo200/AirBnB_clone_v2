#!/usr/bin/env bash

# Configuration for the web server
SERVER_CONFIG="
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    index index.html index.htm;
    error_page 404 /404.html;
    add_header X-Served-By \$hostname;
    
    location / {
        root /var/www/html/;
        try_files \$uri \$uri/ =404;
    }
    
    location /hbnb_static/ {
        alias /data/web_static/current/;
        try_files \$uri \$uri/ =404;
    }
    
    if (\$request_filename ~ redirect_me) {
        rewrite ^ https://sketchfab.com/bluepeno/models permanent;
    }
    
    location = /404.html {
        root /var/www/error/;
        internal;
    }
}
"

# HTML content for the home page
HOME_PAGE_CONTENT="
<!DOCTYPE html>
<html lang='en-US'>
<head>
    <title>Home - AirBnB Clone</title>
</head>
<body>
    <h1>Welcome to AirBnB!</h1>
</body>
</html>
"

# Ensure Nginx is installed
if ! command -v nginx > /dev/null; then
    apt-get update
    apt-get install -y nginx
fi

# Create necessary directories and set permissions
mkdir -p /var/www/html /var/www/error /data/web_static/releases/test /data/web_static/shared
chmod -R 755 /var/www

# Create sample HTML and error pages
echo 'Hello World!' > /var/www/html/index.html
echo -e "Ceci n\x27est pas une page" > /var/www/error/404.html

# Create and link the web static content
echo -e "$HOME_PAGE_CONTENT" > /data/web_static/releases/test/index.html
ln -sf /data/web_static/releases/test /data/web_static/current
chown -hR ubuntu:ubuntu /data

# Deploy the server configuration
echo -e "$SERVER_CONFIG" > /etc/nginx/sites-available/default
ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Start or restart the Nginx service
if ! pgrep -x nginx > /dev/null; then
    service nginx start
else
    service nginx restart
fi

