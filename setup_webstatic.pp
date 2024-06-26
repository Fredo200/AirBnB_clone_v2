#!/usr/bin/puppet apply
# AirBnB clone web server setup and configuration

# Update the package list
exec { 'apt-get-update':
  command => '/usr/bin/apt-get update',
  path    => '/usr/bin:/usr/sbin:/bin',
}

# Remove the current symbolic link if it exists
exec { 'remove-current':
  command => 'rm -rf /data/web_static/current',
  path    => '/usr/bin:/usr/sbin:/bin',
}

# Ensure nginx is installed
package { 'nginx':
  ensure  => installed,
  require => Exec['apt-get-update'],
}

# Ensure the /var/www directory exists
file { '/var/www':
  ensure  => directory,
  mode    => '0755',
  recurse => true,
  require => Package['nginx'],
}

# Create the index.html file in the /var/www/html directory
file { '/var/www/html/index.html':
  content => 'Hello, World!',
  require => File['/var/www'],
}

# Create the 404.html error page
file { '/var/www/error/404.html':
  content => "Ceci n'est pas une page",
  require => File['/var/www'],
}

# Create the directories for static files
exec { 'make-static-files-folder':
  command => 'mkdir -p /data/web_static/releases/test /data/web_static/shared',
  path    => '/usr/bin:/usr/sbin:/bin',
  require => Package['nginx'],
}

# Create the test index.html file for static files
file { '/data/web_static/releases/test/index.html':
  content => @("EOF")
<!DOCTYPE html>
<html lang='en-US'>
  <head>
    <title>Home - AirBnB Clone</title>
  </head>
  <body>
    <h1>Welcome to AirBnB!</h1>
  </body>
</html>
| EOF
  replace => true,
  require => Exec['make-static-files-folder'],
}

# Create a symbolic link to the test release
exec { 'link-static-files':
  command => 'ln -sf /data/web_static/releases/test/ /data/web_static/current',
  path    => '/usr/bin:/usr/sbin:/bin',
  require => [
    Exec['remove-current'],
    File['/data/web_static/releases/test/index.html'],
  ],
}

# Change the ownership of the /data directory
exec { 'change-data-owner':
  command => 'chown -hR ubuntu:ubuntu /data',
  path    => '/usr/bin:/usr/sbin:/bin',
  require => Exec['link-static-files'],
}

# Configure Nginx
file { '/etc/nginx/sites-available/default':
  ensure  => present,
  mode    => '0644',
  content => @("EOF")
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
| EOF
  require => [
    Package['nginx'],
    File['/var/www/html/index.html'],
    File['/var/www/error/404.html'],
    Exec['change-data-owner'],
  ],
}

# Enable the site by linking the configuration file
exec { 'enable-site':
  command => "ln -sf '/etc/nginx/sites-available/default' '/etc/nginx/sites-enabled/default'",
  path    => '/usr/bin:/usr/sbin:/bin',
  require => File['/etc/nginx/sites-available/default'],
}

# Start or restart Nginx to apply the new configuration
exec { 'start-nginx':
  command => 'service nginx restart',
  path    => '/usr/bin:/usr/sbin:/bin',
  require => [
    Exec['enable-site'],
    Package['nginx'],
    File['/data/web_static/releases/test/index.html'],
  ],
}

# Ensure the Nginx service is running
Exec['start-nginx']

