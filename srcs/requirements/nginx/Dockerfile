FROM debian:bookworm

# Utiliser && pour minimiser les couches => gain de vitesse et optimisation de l espace
RUN apt-get update -y \
 && apt-get upgrade -y \
 && apt-get install nginx -y \
 && apt-get install openssl -y \
 && mkdir -p /etc/nginx/ssl \
 && openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=login.42.fr/UID=login" \
 && mkdir -p /var/run/nginx \
 && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf

# EXPOSE
# ENTRYPOINT

# on utilise CMD pour definir le PID 1 (processus lance au demarrage)
CMD ["nginx", "-g", "daemon off;"]