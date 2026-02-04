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
9. [Verification Commands](#9-verification-commands)

---

## 1. Services Overview

This Docker infrastructure provides a **complete and secure web stack** composed of the following services:

| Service         | Port            | Role                           |
|-----------------|-----------------|--------------------------------|
| **NGINX**       | 443             | Web server, reverse proxy, TLS |
| **WordPress**   | 9000            | CMS with PHP-FPM               |
| **MariaDB**     | 3306            | Relational database            |
| **Redis**       | 6379            | In-memory cache                |
| **FTP**         | 21, 21100-21110 | File transfer to WordPress     |
| **Adminer**     | 8080 (internal) | Database management interface  |
| **cAdvisor**    | 8081            | Container monitoring           |
| **Static Site** | 8080            | Portfolio website              |

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

### 1.4 Redis (Cache)

- **Role**: In-memory data store used as a cache for WordPress to improve performance
- **Version**: Latest stable version of Redis
- **Port**: 6379 (internal only, not exposed to host)
- **Memory Limit**: 256 MB
- **Eviction Policy**: `allkeys-lru` (removes least recently used keys when memory is full)
- **Configuration**: `/srcs/requirements/bonus/redis/conf/redis.conf`

**Source**: [Official Redis Documentation](https://redis.io/documentation)

> *"Redis is an open source, in-memory data structure store, used as a database, cache, message broker, and streaming engine."*  
> — [Redis.io](https://redis.io/)

#### How Redis improves WordPress performance:

| Without Redis                        | With Redis                                |
|--------------------------------------|-------------------------------------------|
| Every page load queries the database | Frequently accessed data is cached in RAM |
| Slower response times                | ~1000x faster data retrieval              |
| Higher database load                 | Reduced database queries                  |

#### WordPress Integration:

Redis is integrated via the **Redis Object Cache** plugin, which automatically caches:
- Database query results
- User sessions
- Transient data
- Object cache

### 1.5 FTP Server (File Transfer)

- **Role**: Allows file transfer to/from the WordPress directory via FTP protocol
- **Software**: vsftpd (Very Secure FTP Daemon)
- **Port**: 21 (control) + 21100-21110 (passive data transfer)
- **Root Directory**: `/var/www/wordpress` (same as WordPress volume)
- **Configuration**: `/srcs/requirements/bonus/ftp/conf/vsftpd.conf`

**Source**: [vsftpd Documentation](https://security.appspot.com/vsftpd.html)

> *"vsftpd is a GPL licensed FTP server for UNIX systems, including Linux. It is secure and extremely fast."*  
> — [vsftpd](https://security.appspot.com/vsftpd.html)

#### FTP Connection Details:

| Parameter | Value                          |
|-----------|--------------------------------|
| Host      | `dbhujoo.42.fr` or `127.0.0.1` |
| Port      | `21`                           |
| User      | `ftpuser` (configured in .env) |
| Password  | See `secrets/ftp_password.txt` |
| Protocol  | FTP (passive mode)             |

#### Use Cases:

- Upload custom themes or plugins
- Download backup files
- Edit WordPress files directly
- Manage media uploads

### 1.6 Adminer (Database Management)

- **Role**: Web-based database management interface for MariaDB
- **Version**: Adminer 4.8.1
- **Port**: 8080 (internal, accessed via NGINX reverse proxy)
- **Access**: `https://dbhujoo.42.fr/adminer`

**Source**: [Adminer Documentation](https://www.adminer.org/)

> *"Adminer is a full-featured database management tool written in PHP. It consists of a single file ready to deploy to the target server."*  
> — [Adminer.org](https://www.adminer.org/)

#### Connection Details:

| Parameter | Value                           |
|-----------|---------------------------------|
| Server    | `mariadb`                       |
| Username  | Value from `SQL_USER` in `.env` |
| Password  | See `secrets/db_password.txt`   |
| Database  | `wordpress`                     |

### 1.7 cAdvisor (Container Monitoring)

- **Role**: Real-time monitoring of container resource usage
- **Version**: cAdvisor 0.47.0
- **Port**: 8081
- **Access**: `http://localhost:8081`

**Source**: [cAdvisor GitHub](https://github.com/google/cadvisor)

> *"cAdvisor (Container Advisor) provides container users an understanding of the resource usage and performance characteristics of their running containers."*  
> — [Google cAdvisor](https://github.com/google/cadvisor)

#### Available Metrics:

| Metric  | Description                    |
|---------|--------------------------------|
| CPU     | Usage percentage per container |
| Memory  | RAM usage and limits           |
| Network | Bytes sent/received            |
| Disk    | I/O operations and space       |

### 1.8 Static Site (Portfolio)

- **Role**: Static HTML/CSS/JS website showcasing 42 projects
- **Port**: 8080
- **Access**: `http://localhost:8080`
- **Location**: `/var/www/static` (inside the container)

#### Features:

- Displays all 42 curriculum projects
- Responsive design
- Dark theme with modern styling

### 1.9 Network Architecture

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

### 4.4 Accessing Adminer

**URL**: `https://dbhujoo.42.fr/adminer`

**Connection details**:
- **Server**: `mariadb`
- **Username**: Value from `SQL_USER` in `.env`
- **Password**: See `secrets/db_password.txt`
- **Database**: `wordpress`

### 4.5 Accessing cAdvisor

**URL**: `http://localhost:8081`

No authentication required. Provides real-time container metrics.

### 4.6 Accessing Static Site

**URL**: `http://localhost:8080`

No authentication required. Displays the 42 projects portfolio.

### 4.7 Accessing FTP

**Connection details**:
- **Host**: `127.0.0.1` or `dbhujoo.42.fr`
- **Port**: `21`
- **Username**: `ftpuser`
- **Password**: See `secrets/ftp_password.txt`
- **Protocol**: FTP (passive mode)

**Using command line**:
```bash
ftp 127.0.0.1
```

**Using FileZilla or similar FTP client**:
1. Host: `127.0.0.1`
2. Port: `21`
3. Protocol: FTP
4. Encryption: Plain FTP

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
- `ftp_password.txt`: FTP user password
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
CONTAINER ID   IMAGE              STATUS         PORTS                           NAMES
abc123...      nginx              Up 5 minutes   0.0.0.0:443->443/tcp            nginx
def456...      wordpress          Up 5 minutes                                   wordpress
ghi789...      mariadb            Up 5 minutes                                   mariadb
jkl012...      redis              Up 5 minutes                                   redis
mno345...      ftp                Up 5 minutes   0.0.0.0:21->21/tcp              ftp
pqr678...      static-site        Up 5 minutes   0.0.0.0:8080->8080/tcp          static-site
stu901...      adminer            Up 5 minutes                                   adminer
vwx234...      cadvisor           Up 5 minutes   0.0.0.0:8081->8080/tcp          cadvisor
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

## 9. Verification Commands

This section provides comprehensive commands to verify the proper functioning of all services.

### 9.1 Docker Cleanup Before Testing

**Complete Docker cleanup** (use before fresh testing):
```bash
docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null
```

### 9.2 Project Structure Verification

**Check project structure**:
```bash
ls -la /home/dbhujoo/Bureau/inception/
ls -la /home/dbhujoo/Bureau/inception/srcs/
```

**Expected elements**:
- `srcs/` at the root of the repository
- `Makefile` at the root of the repository
- `docker_compose.yml` inside `srcs/`

### 9.3 Docker Compose Verification

**Check for forbidden elements**:
```bash
# Verify absence of 'network: host'
grep -i "network.*host" /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml

# Verify absence of 'links:'
grep -i "links:" /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml

# Verify presence of 'networks:'
grep -i "networks:" /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml
```

### 9.4 Dockerfile Verification

**Check base images**:
```bash
grep -r "^FROM" /home/dbhujoo/Bureau/inception/srcs/requirements/
```

**Check for forbidden elements**:
```bash
# Verify absence of '--link'
grep -r "\-\-link" /home/dbhujoo/Bureau/inception/

# Verify absence of 'tail -f' in ENTRYPOINT
grep -r "tail -f" /home/dbhujoo/Bureau/inception/srcs/requirements/

# Verify absence of infinite loops
grep -rE "sleep infinity|tail -f /dev/null|tail -f /dev/random" /home/dbhujoo/Bureau/inception/
```

### 9.5 NGINX and TLS Verification

**Check NGINX is only listening on port 443**:
```bash
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

**Test HTTP access (should fail)**:
```bash
curl -I http://dbhujoo.42.fr 2>&1
```

**Test HTTPS access (should work)**:
```bash
curl -kI https://dbhujoo.42.fr
```

**Verify TLS certificate**:
```bash
# Check TLS 1.2
openssl s_client -connect dbhujoo.42.fr:443 -tls1_2 </dev/null 2>/dev/null | grep -E "Protocol|Cipher"

# Check TLS 1.3
openssl s_client -connect dbhujoo.42.fr:443 -tls1_3 </dev/null 2>/dev/null | grep -E "Protocol|Cipher"

# Check certificate dates
echo | openssl s_client -connect dbhujoo.42.fr:443 2>/dev/null | openssl x509 -noout -dates
```

### 9.6 WordPress Verification

**Check WordPress container**:
```bash
docker compose -f /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml ps wordpress
```

**Verify NGINX is NOT in WordPress Dockerfile**:
```bash
grep -i nginx /home/dbhujoo/Bureau/inception/srcs/requirements/wordpress/Dockerfile
```

**Check WordPress volume**:
```bash
docker volume ls
docker volume inspect srcs_wordpress
ls -la /home/dbhujoo/data/wordpress/
```

### 9.7 MariaDB Verification

**Check MariaDB container**:
```bash
docker compose -f /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml ps mariadb
```

**Check MariaDB volume**:
```bash
docker volume inspect srcs_mariadb
```

**Connect to database**:
```bash
docker exec -it mariadb mariadb -u root -p
# Enter the root password from secrets/db_root_password.txt
```

**Database commands** (once connected):
```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
```

### 9.8 Network Verification

**List networks**:
```bash
docker network ls
```

**Inspect the inception network**:
```bash
docker network inspect srcs_inception
```

### 9.9 Redis Verification (Bonus)

**Check Redis container**:
```bash
docker compose -f /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml ps redis
```

**Test Redis connection**:
```bash
docker exec -it redis redis-cli ping
# Expected output: PONG
```

**Check WordPress-Redis integration**:
```bash
docker exec -it wordpress wp redis status --allow-root --path=/var/www/wordpress
```

**View cached keys**:
```bash
docker exec -it redis redis-cli keys '*'
```

### 9.10 FTP Verification (Bonus)

**Check FTP container**:
```bash
docker compose -f /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml ps ftp
```

**Check FTP ports**:
```bash
docker ps --format "table {{.Names}}\t{{.Ports}}" | grep ftp
```

**Test FTP connection**:
```bash
lftp -u ftpuser ftp://localhost
# Enter the FTP password from secrets/ftp_password.txt
```

### 9.11 Static Site Verification (Bonus)

**Check static-site container**:
```bash
docker compose -f /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml ps static-site
```

**Test access**:
```bash
curl -I http://dbhujoo.42.fr:8080/
```

### 9.12 Adminer Verification (Bonus)

**Check Adminer container**:
```bash
docker compose -f /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml ps adminer
```

**Access via browser**: `https://dbhujoo.42.fr/adminer/`

### 9.13 cAdvisor Verification (Bonus)

**Check cAdvisor container**:
```bash
docker compose -f /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml ps cadvisor
```

**Check metrics endpoint**:
```bash
curl http://localhost:8081/metrics | head -50
```

**Access via browser**: `http://localhost:8081`

### 9.14 Persistence Verification

**Procedure after VM reboot**:
```bash
# 1. Reboot the VM
sudo reboot

# 2. After restart, relaunch docker compose
cd /home/dbhujoo/Bureau/inception && make

# 3. Verify everything is working
docker compose -f /home/dbhujoo/Bureau/inception/srcs/docker_compose.yml ps

# 4. Test HTTPS access
curl -kI https://dbhujoo.42.fr
```

### 9.15 Secrets Verification

**Check that secrets are not hardcoded**:
```bash
grep -r "password" --include="*.yml" --include="*.conf" --include="*.sh" /home/dbhujoo/Bureau/inception/
```

**Expected result**: Passwords should not appear in plain text. The project uses Docker Secrets mounted via `/run/secrets/`.

### 9.16 Configuration Change Test

**Example: Change HTTPS port from 443 to 8443**:
```bash
# 1. Edit docker_compose.yml
# Change: ports: - "443:443"
# To:     ports: - "8443:443"

# 2. Update WordPress URLs
docker exec redis redis-cli FLUSHALL
docker exec wordpress wp option update siteurl 'https://dbhujoo.42.fr:8443' --allow-root --path=/var/www/wordpress
docker exec wordpress wp option update home 'https://dbhujoo.42.fr:8443' --allow-root --path=/var/www/wordpress

# 3. Rebuild and restart
cd /home/dbhujoo/Bureau/inception
make re

# 4. Verify
docker ps
curl -kI https://dbhujoo.42.fr:8443
```

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

# Access URLs
https://dbhujoo.42.fr              # WordPress site
https://dbhujoo.42.fr/wp-admin     # WordPress admin
https://dbhujoo.42.fr/adminer      # Adminer (database)
http://localhost:8080              # Static site (portfolio)
http://localhost:8081              # cAdvisor (monitoring)

# Container shell access
docker exec -it nginx bash         # NGINX access
docker exec -it wordpress bash     # WordPress access
docker exec -it mariadb bash       # MariaDB access
docker exec -it redis redis-cli    # Redis CLI
docker exec -it ftp bash           # FTP access
```

---

*Document created on January 29, 2026 by dbhujoo*  
*Last updated on February 3, 2026*  
*Inception Project - 42 School*