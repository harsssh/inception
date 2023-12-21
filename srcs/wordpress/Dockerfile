FROM alpine:3.18.5

# Install packages
RUN apk update && apk upgrade && \
    apk add --no-cache \
    curl fcgi su-exec \
    php82 php82-fpm php82-mysqli php82-json php82-openssl php82-curl \
    php82-zlib php82-xml php82-phar php82-intl php82-dom php82-xmlreader \
    php82-ctype php82-mbstring php82-gd php82-session

# Create symlink
RUN ln -s /usr/bin/php82 /usr/bin/php

# Ensure www-data user exists
# 82 is the standard uid/gid for "www-data" in Alpine
RUN addgroup -g 82 -S www-data ; \
    adduser -u 82 -D -S -G www-data www-data ; true

# Install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Setup directories
ENV WORDPRESS_DIR=/var/www/html
RUN mkdir -p $WORDPRESS_DIR && \
    chown -R www-data:www-data $WORDPRESS_DIR && \
    chmod 755 $WORDPRESS_DIR

# Set working directory
WORKDIR $WORDPRESS_DIR

# Download wordpress
RUN su-exec www-data wp core download --path=$WORDPRESS_DIR

# Copy config files
#COPY ./conf/conf.d/opcache-recommended.ini /usr/local/etc/php/conf.d/
#COPY ./conf/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/

# Copy entrypoint.sh
COPY ./entrypoint.sh /usr/local/bin/

# Volume
VOLUME $WORDPRESS_DIR

# Expose ports
EXPOSE 9000

# Run entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
