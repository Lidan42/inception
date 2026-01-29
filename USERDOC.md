# User Documentation - Inception Project

*Documentation for end users and system administrators*

---

## Table of Contents

1. [Services Overview](#1-services-overview)
2. [Prerequisites](#2-prerequisites)
3. [Starting and Stopping the Project](#3-starting-and-stopping-the-project)
4. [Accessing Services](#4-accessing-services)
5. [Credentials Management](#5-credentials-management)
6. [Service Status Verification](#6-service-status-verification)
7. [Troubleshooting](#7-troubleshooting)
8. [References and Sources](#8-references-and-sources)

---

## 1. Services Overview

This Docker infrastructure provides a **complete and secure web stack** composed of three main services:

### 1.1 NGINX (Web Server & Reverse Proxy)

- **Role**: Front-end web server that handles HTTPS requests and redirects them to WordPress
- **Version**: Latest stable version of NGINX
- **Security**: TLSv1.2 and TLSv1.3 only (obsolete SSL protocols disabled)
- **Port**: 443 (HTTPS)
- **Configuration**: `/srcs/requirements/nginx/conf/nginx.conf`

**Source**: [Official NGINX Documentation](https://nginx.org/en/docs/)

> *"NGINX is a web server that can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache."*  
> — [nginx.org](https://www.nginx.com/resources/glossary/nginx/)

### 1.2 WordPress (CMS)

- **Role**: Content Management System (CMS) for creating and managing the website
- **Version**: Latest stable version of WordPress
- **PHP Processor**: PHP-FPM 8.2 (FastCGI Process Manager)
- **Location**: `/var/www/wordpress` (inside the container)
- **Persistence**: Docker volume mounted on `/home/dbhujoo/data/wordpress`

**Source**: [Official WordPress Documentation](https://wordpress.org/documentation/)

> *"WordPress is a free and open-source content management system written in PHP and paired with a MySQL or MariaDB database."*  
> — [WordPress.org](https://wordpress.org/about/)

### 1.3 MariaDB (Database)

- **Role**: Relational database management system for storing WordPress content
- **Version**: Latest stable version of MariaDB
- **Location**: `/var/lib/mysql` (inside the container)
- **Persistence**: Docker volume mounted on `/home/dbhujoo/data/mariadb`
- **Socket**: `/run/mysqld/mysqld.sock`

**Source**: [Official MariaDB Documentation](https://mariadb.org/documentation/)

> *"MariaDB Server is one of the most popular open source relational databases. It's made by the original developers of MySQL and guaranteed to stay open source."*  
> — [MariaDB.org](https://mariadb.org/about/)

### 1.4 Network Architecture

The three containers communicate via a **Docker bridge network** named `inception`, isolating the infrastructure from the host network while allowing inter-container communication.

**Source**: [Docker Networking Documentation](https://docs.docker.com/network/)

> *"Bridge networks are the default network driver. If you don't specify a driver, this is the type of network you are creating. Bridge networks are commonly used when your application runs in a container that needs to communicate with other containers on the same host."*  
> — [Docker Docs](https://docs.docker.com/network/bridge/)

---

## 2. Prerequisites

Before starting the project, ensure the following elements are installed and configured:

### 2.1 Required Software

- **Docker Engine** (version 20.10 or higher)
- **Docker Compose** (version 2.0 or higher)
- **Make** (to use Makefile commands)

**Installation verification**:

```bash
docker --version          # Docker version 24.0.0 or higher
docker compose version    # Docker Compose version v2.20.0 or higher
make --version           # GNU Make 4.3 or higher
```

**Installation source**: [Get Docker](https://docs.docker.com/get-docker/)

### 2.2 Data Directory Creation

Docker volumes require directories on the host:

```bash
sudo mkdir -p /home/dbhujoo/data/mariadb
sudo mkdir -p /home/dbhujoo/data/wordpress
sudo chown -R $USER:$USER /home/dbhujoo/data
```

### 2.3 Configuration File

The `.env` file must be present in the `/home/dbhujoo/Desktop/inception/` directory with the necessary environment variables.

---

## 3. Starting and Stopping the Project

The project uses a **Makefile** to simplify common operations.

### 3.1 Starting the Infrastructure

**Command**:
```bash
make up
```

**Details**:
- Builds Docker images from Dockerfiles
- Starts all services in the background (`-d`)
- Creates necessary networks and volumes
- Containers automatically restart on failure (`restart: on-failure`)

**Equivalent command**:
```bash
docker compose -f ./srcs/requirements/docker-compose.yml up -d --build
```

**Source**: [Docker Compose up command](https://docs.docker.com/engine/reference/commandline/compose_up/)

### 3.2 Stopping the Infrastructure

**Complete stop** (removes containers):
```bash
make down
```

**Simple stop** (containers stopped but not removed):
```bash
make stop
```

**Restart** (after a stop):
```bash
make start
```

**Source**: [Docker Compose down command](https://docs.docker.com/engine/reference/commandline/compose_down/)

### 3.3 Restarting the Infrastructure

To completely restart (stop + start):
```bash
make re
```

### 3.4 Cleanup

**Docker resources cleanup**:
```bash
make clean
```
- Stops containers
- Removes unused images, containers, and networks
- **Warning**: Data volumes are preserved

**Complete cleanup (with data deletion)**:
```bash
make fclean
```
- Executes `make clean`
- **DELETES ALL DATA** in `/home/dbhujoo/data/mariadb` and `/home/dbhujoo/data/wordpress`
- ⚠️ **Use with caution**: this action is irreversible

**Source**: [Docker system prune](https://docs.docker.com/engine/reference/commandline/system_prune/)

---

## 4. Accessing Services

### 4.1 Accessing the WordPress Site

**URL**: `https://dbhujoo.42.fr` (or the URL defined in your `WP_URL` variable)

**Protocol**: HTTPS only (TLSv1.2 or TLSv1.3)

**Note**: If using a local domain, make sure to configure your `/etc/hosts` file:
```bash
sudo nano /etc/hosts
```
Add:
```
127.0.0.1    dbhujoo.42.fr
```

**SSL Certificate**:
- A self-signed certificate is used
- Your browser will display a security warning
- Click "Advanced" then "Accept the risk and continue"

**Source**: [HTTPS on Wikipedia](https://en.wikipedia.org/wiki/HTTPS)

### 4.2 Accessing the WordPress Administration Panel

**URL**: `https://dbhujoo.42.fr/wp-admin`

**Administrator credentials**:
- **Username**: Defined in the `WP_ADMIN_USER` variable (`.env` file)
- **Password**: Stored in `/home/dbhujoo/Desktop/inception/secrets/wp_admin_password.txt`

**Available features**:
- Content management (posts, pages, media)
- Theme and plugin installation
- User management
- Site configuration
- Statistics consultation

**Source**: [WordPress Admin Dashboard](https://wordpress.org/support/article/administration-screens/)

> *"The Administration Screen provides access to the control features of your WordPress installation. From the navigation menu on the left of the screen you can select an Administration Screen, or you can choose an item from the drop-down menus."*  
> — [WordPress Support](https://wordpress.org/support/article/administration-screens/)

### 4.3 Accessing the MariaDB Database

**From inside the container**:
```bash
docker exec -it mariadb bash
mysql -u root -p
```
The root password is located in `/home/dbhujoo/Desktop/inception/secrets/db_root_password.txt`

**From the WordPress container**:
```bash
docker exec -it wordpress bash
mysql -h mariadb -u $SQL_USER -p
```

**Note**: MariaDB is not exposed on an external port for security reasons. Access is only through the internal Docker network.

**Source**: [MariaDB Command-line Client](https://mariadb.com/kb/en/mysql-command-line-client/)

---

## 5. Credentials Management

### 5.1 Secrets Location

All passwords are stored in the directory:
```
/home/dbhujoo/Desktop/inception/secrets/
```

**Secret files**:
- `db_password.txt`: WordPress user password for the database
- `db_root_password.txt`: MariaDB root password
- `wp_admin_password.txt`: WordPress administrator password
- `wp_user_password.txt`: Standard WordPress user password

**Recommended permissions**:
```bash
chmod 600 /home/dbhujoo/Desktop/inception/secrets/*.txt
```

**Source**: [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)

> *"In terms of Docker Swarm services, a secret is a blob of data, such as a password, SSH private key, SSL certificate, or another piece of data that should not be transmitted over a network or stored unencrypted."*  
> — [Docker Documentation](https://docs.docker.com/engine/swarm/secrets/)

### 5.2 Viewing Credentials

To read a password:
```bash
cat /home/dbhujoo/Desktop/inception/secrets/wp_admin_password.txt
```

### 5.3 Modifying Credentials

**⚠️ Important procedure**:

1. **Stop the infrastructure**:
   ```bash
   make down
   ```

2. **Modify the secret file**:
   ```bash
   echo "new_password" > /home/dbhujoo/Desktop/inception/secrets/wp_admin_password.txt
   ```

3. **Clean the data (if necessary)**:
   ```bash
   make fclean
   ```
   ⚠️ This deletes all data!

4. **Restart the infrastructure**:
   ```bash
   make up
   ```

**Note**: For WordPress, you can also reset the password via the administration panel once logged in.

### 5.4 Environment Variables

The `.env` file contains non-sensitive information such as:
- `WP_URL`: WordPress site URL
- `WP_TITLE`: Site title
- `WP_ADMIN_USER`: Admin username
- `WP_ADMIN_EMAIL`: Administrator email
- `SQL_DATABASE`: Database name
- `SQL_USER`: Database user

**Source**: [Environment Variables in Compose](https://docs.docker.com/compose/environment-variables/)

---

## 6. Service Status Verification

### 6.1 Quick Verification

**View active containers**:
```bash
make status
```
or
```bash
docker ps
```

**Expected output**:
```
CONTAINER ID   IMAGE              STATUS         PORTS                  NAMES
abc123...      nginx              Up 5 minutes   0.0.0.0:443->443/tcp   nginx
def456...      wordpress          Up 5 minutes                          wordpress
ghi789...      mariadb            Up 5 minutes                          mariadb
```

**Source**: [Docker ps command](https://docs.docker.com/engine/reference/commandline/ps/)

### 6.2 Viewing Logs

**All services** (real-time follow mode):
```bash
make logs
```

**Specific service**:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

**Follow logs in real-time**:
```bash
docker logs -f wordpress
```

**Source**: [Docker logs command](https://docs.docker.com/engine/reference/commandline/logs/)

### 6.3 Health Tests

**NGINX test**:
```bash
curl -k https://localhost
```
Should return the WordPress homepage.

**MariaDB test**:
```bash
docker exec mariadb mysqladmin -u root -p$(cat secrets/db_root_password.txt) ping
```
Should return: `mysqld is alive`

**WordPress test**:
```bash
docker exec wordpress wp core is-installed --allow-root --path='/var/www/wordpress'
```
Should return exit code 0 if WordPress is installed.

**Source**: [WordPress CLI](https://wp-cli.org/)

### 6.4 Volume Verification

**List volumes**:
```bash
docker volume ls
```

**Inspect a volume**:
```bash
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb
```

**Check used disk space**:
```bash
du -sh /home/dbhujoo/data/mariadb
du -sh /home/dbhujoo/data/wordpress
```

**Source**: [Docker Volumes](https://docs.docker.com/storage/volumes/)

### 6.5 Network Verification

**List networks**:
```bash
docker network ls
```

**Inspect the inception network**:
```bash
docker network inspect srcs_inception
```

This command displays containers connected to the network and their IP addresses.

---

## 7. Troubleshooting

### 7.1 Common Issues

#### Error: "Port 443 already in use"

**Cause**: Another service is already using port 443.

**Solution**:
```bash
sudo lsof -i :443
sudo kill <PID>
```

#### Error: "Cannot connect to MariaDB"

**Cause**: MariaDB is not ready yet when WordPress starts.

**Solution**: The WordPress script waits automatically. Check the logs:
```bash
docker logs wordpress
```

#### Blank page or 502 error

**Cause**: PHP-FPM or WordPress is not responding.

**Solution**:
```bash
docker restart wordpress
make logs
```

#### Invalid SSL certificate

**Cause**: Self-signed certificate.

**Solution**: This is normal for a development environment. Accept the exception in your browser.

### 7.2 Complete Restart

In case of persistent issues:
```bash
make down
make clean
make up
```

### 7.3 Total Reset

⚠️ **Deletes all data**:
```bash
make fclean
make up
```

**Source**: [Docker Compose Troubleshooting](https://docs.docker.com/compose/troubleshooting/)

---

## 8. References and Sources

### 8.1 Official Documentation

1. **Docker**
   - [Docker Documentation](https://docs.docker.com/) - Complete Docker documentation
   - [Docker Compose](https://docs.docker.com/compose/) - Docker Compose guide
   - [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
   - [Docker Networking](https://docs.docker.com/network/)
   - [Docker Volumes](https://docs.docker.com/storage/volumes/)

2. **NGINX**
   - [NGINX Documentation](https://nginx.org/en/docs/) - Official documentation
   - [NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
   - [Configuring HTTPS servers](https://nginx.org/en/docs/http/configuring_https_servers.html)
   - [NGINX SSL/TLS](https://docs.nginx.com/nginx/admin-guide/security-controls/terminating-ssl-http/)

3. **WordPress**
   - [WordPress Documentation](https://wordpress.org/documentation/) - Complete documentation
   - [WordPress CLI (WP-CLI)](https://wp-cli.org/) - Command-line interface
   - [Installing WordPress](https://wordpress.org/support/article/how-to-install-wordpress/)
   - [WordPress Administration Screens](https://wordpress.org/support/article/administration-screens/)

4. **MariaDB**
   - [MariaDB Documentation](https://mariadb.org/documentation/) - Official documentation
   - [MariaDB Server](https://mariadb.com/kb/en/mariadb-server/)
   - [Getting Started with MariaDB](https://mariadb.com/kb/en/getting-started-with-mariadb/)
   - [mysql Command-line Client](https://mariadb.com/kb/en/mysql-command-line-client/)

5. **PHP-FPM**
   - [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)
   - [FastCGI Process Manager](https://www.php.net/manual/en/install.fpm.configuration.php)

### 8.2 Articles and Tutorials

1. **Containerization**
   - [What is a Container?](https://www.docker.com/resources/what-container/) - Docker.com
   - [Docker Overview](https://docs.docker.com/get-started/overview/)

2. **Security**
   - [Docker Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html) - OWASP
   - [TLS Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS) - Mozilla

3. **WordPress & Docker**
   - [Dockerizing a WordPress Site](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose)
   - [WordPress Docker Best Practices](https://make.wordpress.org/cli/handbook/guides/hosting/)

### 8.3 Technical Specifications

- **TLS 1.2**: [RFC 5246](https://datatracker.ietf.org/doc/html/rfc5246)
- **TLS 1.3**: [RFC 8446](https://datatracker.ietf.org/doc/html/rfc8446)
- **HTTP/2**: [RFC 7540](https://datatracker.ietf.org/doc/html/rfc7540)
- **FastCGI**: [FastCGI Specification](https://fastcgi-archives.github.io/FastCGI_Specification.html)

### 8.4 Standards and Best Practices

- [The Twelve-Factor App](https://12factor.net/) - Methodology for cloud-native applications
- [Docker Official Images](https://docs.docker.com/docker-hub/official_images/) - Official images guide
- [Security Best Practices for WordPress](https://wordpress.org/support/article/hardening-wordpress/)

---

## Appendix: Quick Reference Commands

```bash
# Starting
make up               # Start the infrastructure
make down             # Stop and remove containers
make stop             # Stop without removing
make start            # Restart after a stop
make re               # Complete restart

# Monitoring
make status           # Container status
make logs             # View all logs
docker logs <name>    # Logs of a specific service

# Cleanup
make clean            # Clean Docker resources
make fclean           # Complete cleanup + data

# Access
https://dbhujoo.42.fr              # WordPress site
https://dbhujoo.42.fr/wp-admin     # WordPress admin
docker exec -it mariadb bash       # MariaDB access
docker exec -it wordpress bash     # WordPress access
docker exec -it nginx bash         # NGINX access
```

---

*Document created on January 29, 2026 by dbhujoo*  
*Inception Project - 42 School*