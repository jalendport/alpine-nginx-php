FROM alpine:edge
MAINTAINER Jack McNicol <jack@mcpickle.com.au>

ENV TERM dumb

RUN set -x && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade

RUN apk add --update --no-cache \
    wget \
    nginx \
    supervisor \
    bash \
    curl \
    git \
    vim \
    php7 \
    php7-fpm \
    php7-ctype \
    php7-session \
    php7-dom \
    php7-zlib \
    php7-mbstring \
    php7-mcrypt \
    php7-openssl \
    php7-xml \
    php7-json \
    php7-gd \
    php7-opcache \
    php7-pdo \
    php7-pdo_mysql \
    php7-iconv \
    php7-curl \
    php7-phar \
    php7-dom && \
    rm -rf /var/cache/apk/*

RUN curl -sS https://getcomposer.org/installer | php7 -- --install-dir=/usr/bin --filename=composer

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./default.conf /etc/nginx/conf.d/
COPY ./supervisord.conf /etc/supervisord.conf

# tweak nginx config
RUN sed -i -e "s@}@application/x-font-ttf ttf; font/opentype otf; application/vnd.ms-fontobject eot; font/x-woff woff;}@g" /etc/nginx/mime.types

# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php7/php.ini  && \
    sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 30M/g" /etc/php7/php.ini && \
    sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 30M/g" /etc/php7/php.ini && \
    sed -i -e "s/memory_limit\s*=\s*128M/memory_limit = 256M/g" /etc/php7/php.ini && \
    sed -i -e 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php7/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php7/php-fpm.conf && \
    sed -i -e "s@pid = /run/php/php7.0-fpm.pid@pid = /var/run/php7.0-fpm.pid@g" /etc/php7/php-fpm.conf && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s/^;clear_env = no$/clear_env = no/" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /etc/php7/php-fpm.d/www.conf

#
# fix ownership of sock file for php-fpm as our version of nginx runs as nginx
RUN sed -i -e "s/user = nobody/user = nginx/g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s/group = nobody/group = nginx/g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s/;listen.owner = nobody/listen.owner = nginx/g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s/;listen.group = nobody/listen.group = nginx/g" /etc/php7/php-fpm.d/www.conf && \
    sed -i -e "s@listen = 127.0.0.1:9000@listen = /var/run/php7-fpm.sock@g" /etc/php7/php-fpm.d/www.conf && \
    find /etc/php7/php-fpm.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# setup nginx public dir
RUN mkdir -p /app/public
ADD index.php /app/public/index.php

# Start Supervisord
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh
# Expose Ports
EXPOSE 443 80

# Start Supervisord
CMD ["/start.sh"]
