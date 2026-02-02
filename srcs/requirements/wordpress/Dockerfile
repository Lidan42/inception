FROM debian:bookworm

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
        wget \
        php8.2 \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-redis \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://wordpress.org/wordpress-6.7.1.tar.gz -P /var/www \
    && cd /var/www && tar -xzf wordpress-6.7.1.tar.gz && rm wordpress-6.7.1.tar.gz \
    && chown -R www-data:www-data /var/www/wordpress \
    && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

EXPOSE 9000

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/script.sh /

RUN chmod +x /script.sh

CMD ["/script.sh"]
