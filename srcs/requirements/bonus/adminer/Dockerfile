FROM debian:bookworm

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
        php8.2 \
        php8.2-mysql \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Download Adminer
RUN mkdir -p /var/www/adminer \
    && wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
       -O /var/www/adminer/index.php \
    && chown -R www-data:www-data /var/www/adminer

WORKDIR /var/www/adminer

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
