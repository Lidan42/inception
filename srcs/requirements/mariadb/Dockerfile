FROM debian:bookworm

RUN apt update -y \
    && apt upgrade -y \
    && apt-get install mariadb-server -y \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 3306

ENTRYPOINT ["/bin/sh", "/script.sh"]