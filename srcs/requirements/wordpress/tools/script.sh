#!/bin/sh

set -e

SQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

echo "Waiting for MariaDB to be ready..."
while ! mariadb -h mariadb -u${SQL_USER} -p${SQL_PASSWORD} -e "SELECT 1;" 2>/dev/null; do
	echo "MariaDB is unavailable - sleeping"
	sleep 2
done

echo "MariaDB is up - configuring WordPress"

# Configuration wp-config.php
if [ ! -f /var/www/wordpress/wp-config.php ]; then
	wp config create --allow-root \
		--dbname=${SQL_DATABASE} \
		--dbuser=${SQL_USER} \
		--dbpass=${SQL_PASSWORD} \
		--dbhost=mariadb:3306 \
		--path='/var/www/wordpress'
fi

# Installation WordPress (idempotente)
if ! wp core is-installed --allow-root --path='/var/www/wordpress' 2>/dev/null; then
	wp core install --allow-root \
		--url=https://${WP_URL} \
		--title="${WP_TITLE}" \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASSWORD} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--path='/var/www/wordpress'
fi

# Création utilisateur (idempotente)
if ! wp user get ${WP_USER} --allow-root --path='/var/www/wordpress' 2>/dev/null; then
	wp user create --allow-root \
		${WP_USER} ${WP_USER_EMAIL} \
		--user_pass=${WP_USER_PASSWORD} \
		--role=author \
		--path='/var/www/wordpress'
fi

# Configuration Redis
wp config set WP_REDIS_HOST 'redis' --allow-root --path='/var/www/wordpress'
wp config set WP_REDIS_PORT 6379 --allow-root --path='/var/www/wordpress' --raw

# Installation et activation du plugin Redis Object Cache
if ! wp plugin is-installed redis-cache --allow-root --path='/var/www/wordpress' 2>/dev/null; then
	wp plugin install redis-cache --activate --allow-root --path='/var/www/wordpress'
fi
wp redis enable --allow-root --path='/var/www/wordpress' 2>/dev/null || true

exec /usr/sbin/php-fpm8.2 -F   