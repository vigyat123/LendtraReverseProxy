#!/bin/bash

set -e

sudo su
chmod 755 /etc/nginx/nginx.conf
# Remove unpacked application artifacts
if [[ -f /etc/nginx/nginx.conf ]]; then
    rm /etc/nginx/nginx.conf
fi
cat > /etc/nginx/nginx.conf <<'EOF'
#user  nobody;
#Defines which Linux system user will own and run the Nginx server
worker_processes  1;
#Referes to single threaded process. Generally set to be equal to the number of CPUs or cores.
#error_log  logs/error.log; #error_log  logs/error.log  notice;
#Specifies the file where server logs. 
#pid        logs/nginx.pid;
#nginx will write its master process ID(PID).
events {
    worker_connections  1024;
    # worker_processes and worker_connections allows you to calculate maxclients value: 
    # max_clients = worker_processes * worker_connections
}
http {
    include       mime.types;
    # anything written in /opt/nginx/conf/mime.types is interpreted as if written inside the http { } block
    default_type  application/octet-stream;
    #
    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';
    #access_log  logs/access.log  main;
    sendfile        on;
    # If serving locally stored static files, sendfile is essential to speed up the server,
    # But if using as reverse proxy one can deactivate it
    
    tcp_nopush     on;
    # works opposite to tcp_nodelay. Instead of optimizing delays, it optimizes the amount of data sent at once.
    #keepalive_timeout  0;
    keepalive_timeout  65;
    # timeout during which a keep-alive client connection will stay open.
    gzip  on;
    # tells the server to use on-the-fly gzip compression.
    server {
        # You would want to make a separate file with its own server block for each virtual domain
        # on your server and then include them.
#       listen       443;
        #tells Nginx the hostname and the TCP port where it should listen for HTTP connections.
        # listen 80; is equivalent to listen *:80;
        
#       server_name  _;
        # lets you doname-based virtual hosting
        #charset koi8-r;
        #access_log  logs/host.access.log  main;
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name ec2-54-89-207-212.compute-1.amazonaws.com;
        return 302 https://$server_name$request_uri;
        
#       root   /tmp/codedeploy-deployment-staging-area/;
#       index  index.html index.htm;
        
#        location / {
#            root   /tmp/codedeploy-deployment-staging-area/;
#            index  index.html index.htm;
#        }
        
#        location /usr/share/tomcat7-codedeploy {
#            proxy_pass       http://localhost:8080;
#            proxy_set_header X-Real-IP $remote_addr;
#            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#            proxy_set_header Host $http_host;
#        }
#        location /usr/share/tomcat7-codedeploy {
#            try_files $uri $uri/;
         }
        
        #error_page  404              /404.html;
        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}
        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}
        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        location ~ /\.ht {
            deny  all;
        }
    }
    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;
    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}
    # HTTPS server
    #
    server {
        listen 443 ssl http2 default_server;
        listen [::]:443 ssl http2 default_server;
        server_name  ec2-54-89-207-212.compute-1.amazonaws.com;
        root   /tmp/codedeploy-deployment-staging-area/;
        index  index.html index.htm;
        ssl_certificate      nginx-selfsigned.crt;
        ssl_certificate_key  nginx-selfsigned.key;
        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;
        location /usr/share/tomcat7-codedeploy {
             try_files $uri $uri/;
         }
    }
}
EOF
service nginx start
