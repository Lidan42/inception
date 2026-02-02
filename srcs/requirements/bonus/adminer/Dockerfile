FROM debian:bookworm

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
        php8.2 \
        php8.2-fpm \
        php8.2-mysql \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Download Adminer
RUN mkdir -p /var/www/adminer \
    && wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
       -O /var/www/adminer/index.php \
    && chown -R www-data:www-data /var/www/adminer

# Configure PHP-FPM to listen on port 9001
RUN sed -i 's/listen = .*/listen = 9001/' /etc/php/8.2/fpm/pool.d/www.conf \
    && sed -i 's/;clear_env = no/clear_env = no/' /etc/php/8.2/fpm/pool.d/www.conf

RUN mkdir -p /run/php

EXPOSE 9001

CMD ["/usr/sbin/php-fpm8.2", "-F"]
