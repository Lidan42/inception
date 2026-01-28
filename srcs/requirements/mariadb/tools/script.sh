#!/bin/sh
set -e

# Lecture des secrets
SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
SQL_PASSWORD=$(cat /run/secrets/db_password)

# setup des repertoire + acces
DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
SOCKET_DIR="$(dirname "$SOCKET")"
mkdir -p "$SOCKET_DIR"
chown -R mysql:mysql "$SOCKET_DIR" "$DATADIR"

# initialisation de la db 

if [ ! -d "$DATADIR/mysql" ]; then
  mariadb-install-db \
    --user=mysql \
    --datadir="$DATADIR" \
    --auth-root-authentication-method=normal
fi

# Démarrage temporaire de MariaDB
mysqld_safe --datadir="$DATADIR" --socket="$SOCKET" &

# Attente que MariaDB soit prêt (attente de 60 sec avant de commencer a envoyer les requetes )

i=0
until mysqladmin --protocol=socket -S "$SOCKET" ping >/dev/null 2>&1; do
  i=$((i + 1))
  [ "$i" -gt 60 ] && echo "Timeout: MariaDB doesn't start" >&2 && exit 1
  sleep 1
done


# Fonctions de test d'authentification

mysql_root_nopass() {
  mysql --protocol=socket -S "$SOCKET" -uroot -e "SELECT 1" >/dev/null 2>&1
}

mysql_root_pass() {
  mysql --protocol=socket -S "$SOCKET" -uroot -p"$SQL_ROOT_PASSWORD" -e "SELECT 1" >/dev/null 2>&1
}


# Init SQL idempotente 

init_sql() {
  mysql --protocol=socket -S "$SOCKET" "$@" <<SQL
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%'
  IDENTIFIED BY '${SQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.*
  TO \`${SQL_USER}\`@'%';

FLUSH PRIVILEGES;
SQL
}


# Logique d'auth root

if mysql_root_nopass; then
  init_sql -uroot
  mysql --protocol=socket -S "$SOCKET" -uroot \
    -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

elif mysql_root_pass; then
  init_sql -uroot -p"$SQL_ROOT_PASSWORD"

else
  echo "fail root auth: check SQL_ROOT_PASSWORD or datadir" >&2
  exit 1
fi

# Arrêt propre et démarrage final

mysqladmin --protocol=socket -S "$SOCKET" -uroot -p"$SQL_ROOT_PASSWORD" shutdown

exec mysqld --datadir="$DATADIR" --socket="$SOCKET"
