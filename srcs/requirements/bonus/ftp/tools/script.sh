#!/bin/sh

set -e

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# creation dun user ftp s il existe pas
if ! id "${FTP_USER}" >/dev/null 2>&1; then
    echo "Creating FTP user: ${FTP_USER}"
    adduser --disabled-password --gecos "" ${FTP_USER}
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
    
    # ajout de l user au groupe www-data pour lacces aux fichiers wordpress
    usermod -aG www-data ${FTP_USER}
fi

# donne les permission a au dossier wordpress
chown -R www-data:www-data /var/www/wordpress
chmod -R 775 /var/www/wordpress

# Update pasv_address avec le hostname/IP si donner
if [ -n "${FTP_HOST}" ]; then
    sed -i "s/pasv_address=.*/pasv_address=${FTP_HOST}/" /etc/vsftpd.conf
fi

echo "Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf
