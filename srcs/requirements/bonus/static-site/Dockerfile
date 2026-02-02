FROM debian:bookworm

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY site/ /var/www/static/

RUN chown -R www-data:www-data /var/www/static

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
