# Developer Documentation - Inception Project

*Technical documentation for developers and contributors*

---

## Table of Contents

1. [Environment Setup](#1-environment-setup)
2. [Project Structure](#2-project-structure)
3. [Building and Launching](#3-building-and-launching)
4. [Container and Volume Management](#4-container-and-volume-management)
5. [Data Storage and Persistence](#5-data-storage-and-persistence)
6. [Configuration Files Reference](#6-configuration-files-reference)
7. [Debugging and Development](#7-debugging-and-development)
8. [References](#8-references)

---

## 1. Environment Setup

### 1.1 Prerequisites

Before setting up the development environment, ensure the following are installed:

| Software | Minimum Version | Verification Command |
|----------|----------------|---------------------|
| Docker Engine | 20.10+ | `docker --version` |
| Docker Compose | 2.0+ | `docker compose version` |
| Make | 4.0+ | `make --version` |
| Git | 2.0+ | `git --version` |

**Installation on Debian/Ubuntu:**
```bash
# Docker
sudo apt-get update
sudo apt-get install docker.io docker-compose-v2
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

**Source**: [Docker Installation Guide](https://docs.docker.com/engine/install/debian/)

### 1.2 Clone the Repository

```bash
git clone <repository-url> inception
cd inception
```

### 1.3 Host Configuration

Configure the local domain in `/etc/hosts`:
```bash
echo "127.0.0.1    dbhujoo.42.fr" | sudo tee -a /etc/hosts
```

**Verify configuration:**
```bash
grep "dbhujoo.42.fr" /etc/hosts
```

### 1.4 Data Directories Setup

Create the required data directories for Docker volumes:
```bash
sudo mkdir -p /home/dbhujoo/data/mariadb
sudo mkdir -p /home/dbhujoo/data/wordpress
sudo chown -R $USER:$USER /home/dbhujoo/data
```

**Why these directories?**
- Docker bind mounts require existing directories on the host
- Data persists outside containers for durability
- Allows direct access to files for debugging

**Source**: [Docker Bind Mounts](https://docs.docker.com/storage/bind-mounts/)

### 1.5 Secrets Configuration

The project uses Docker secrets for sensitive data. Create the secrets files:

```bash
# Navigate to secrets directory
cd secrets/

# Create secret files (replace with secure passwords)
echo "your_db_password" > db_password.txt
echo "your_db_root_password" > db_root_password.txt
echo "your_wp_admin_password" > wp_admin_password.txt
echo "your_wp_user_password" > wp_user_password.txt

# Set secure permissions
chmod 600 *.txt
```

**Secret files structure:**
```
secrets/
├── db_password.txt         # MariaDB user password
├── db_root_password.txt    # MariaDB root password
├── wp_admin_password.txt   # WordPress admin password
└── wp_user_password.txt    # WordPress user password
```

**Source**: [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)

### 1.6 Environment Variables (.env file)

Create the `.env` file in the project root:

```bash
# Database Configuration
SQL_DATABASE=wordpress
SQL_USER=wpuser

# WordPress Configuration
WP_URL=dbhujoo.42.fr
WP_TITLE=Inception
WP_ADMIN_USER=admin
WP_ADMIN_EMAIL=admin@dbhujoo.42.fr
WP_USER=author
WP_USER_EMAIL=author@dbhujoo.42.fr
```

**Note**: Never commit `.env` files containing sensitive data to version control.

**Source**: [Docker Compose Environment Variables](https://docs.docker.com/compose/environment-variables/)

---

## 2. Project Structure

### 2.1 Directory Tree

```
inception/
├── Makefile                          # Build automation
├── README.md                         # Project overview
├── USERDOC.md                        # User documentation
├── DEVDEC.md                         # Developer documentation
├── .env                              # Environment variables (not in git)
├── secrets/                          # Docker secrets
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── docker_compose.yml            # Docker Compose configuration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile            # MariaDB image definition
        │   ├── conf/
        │   │   └── 50-server.cnf     # MariaDB configuration
        │   └── tools/
        │       └── script.sh         # Database initialization script
        ├── nginx/
        │   ├── Dockerfile            # NGINX image definition
        │   ├── conf/
        │   │   └── nginx.conf        # NGINX configuration
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile            # WordPress image definition
        │   ├── conf/
        │   │   └── www.conf          # PHP-FPM pool configuration
        │   └── tools/
        │       └── script.sh         # WordPress setup script
        └── bonus/
            └── redis/
                ├── Dockerfile        # Redis image definition
                └── conf/
                    └── redis.conf    # Redis configuration
```

### 2.2 Service Architecture

```
┌───────────────────────────────────────────────────────────────────┐
│                          HOST MACHINE                              │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │                    Docker Network: inception                  │ │
│  │                                                               │ │
│  │   ┌─────────┐      ┌─────────────┐      ┌──────────┐        │ │
│  │   │  NGINX  │──────│  WordPress  │──────│ MariaDB  │        │ │
│  │   │ :443    │ PHP  │  :9000      │ SQL  │  :3306   │        │ │
│  │   │         │ FPM  │  (PHP-FPM)  │      │          │        │ │
│  │   └────┬────┘      └──────┬──────┘      └────┬─────┘        │ │
│  │        │                  │                   │              │ │
│  │        │                  │ cache             │              │ │
│  │        │                  ▼                   │              │ │
│  │        │            ┌──────────┐              │              │ │
│  │        │            │  Redis   │              │              │ │
│  │        │            │  :6379   │              │              │ │
│  │        │            │ (cache)  │              │              │ │
│  │        │            └──────────┘              │              │ │
│  │        │                                      │              │ │
│  └────────┼──────────────────────────────────────┼──────────────┘ │
│           │                                      │                │
│  ┌────────▼──────────────────────────────────────▼──────────────┐ │
│  │                      Docker Volumes                           │ │
│  │   /home/dbhujoo/data/wordpress  /home/dbhujoo/data/mariadb    │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                              │                                     │
└──────────────────────────────┼─────────────────────────────────────┘
                               │
                       Port 443 (HTTPS)
                               │
                               ▼
                          Browser/Client
```

### 2.3 Container Dependencies

```yaml
# Startup order (managed by depends_on)
1. mariadb    → Starts first (no dependencies)
2. redis      → Starts independently (no dependencies)
3. wordpress  → Waits for mariadb (uses redis for caching)
4. nginx      → Waits for wordpress
```

**Source**: [Docker Compose depends_on](https://docs.docker.com/compose/compose-file/compose-file-v3/#depends_on)

---

## 3. Building and Launching

### 3.1 Makefile Commands Reference

| Command | Description | Docker Equivalent |
|---------|-------------|-------------------|
| `make up` | Build and start all services | `docker compose up -d --build` |
| `make down` | Stop and remove containers | `docker compose down` |
| `make stop` | Stop containers (keep state) | `docker compose stop` |
| `make start` | Start stopped containers | `docker compose start` |
| `make re` | Rebuild and restart | `make down && make up` |
| `make clean` | Remove containers + prune | `docker system prune -af` |
| `make fclean` | Full clean + delete data | Removes volume data |
| `make status` | Show container status | `docker ps` |
| `make logs` | Follow all logs | `docker compose logs -f` |

### 3.2 Building the Project

**First time setup:**
```bash
# 1. Ensure all prerequisites are met
docker --version && docker compose version

# 2. Configure hosts and directories
echo "127.0.0.1    dbhujoo.42.fr" | sudo tee -a /etc/hosts
sudo mkdir -p /home/dbhujoo/data/{mariadb,wordpress}
sudo chown -R $USER:$USER /home/dbhujoo/data

# 3. Build and launch
make up
```

**Build process explained:**
```bash
# What 'make up' does:
docker compose -f ./srcs/requirements/docker-compose.yml up -d --build

# Breakdown:
# -f ./srcs/requirements/docker-compose.yml  → Specify compose file location
# up                                          → Create and start containers
# -d                                          → Detached mode (background)
# --build                                     → Always rebuild images
```

**Source**: [Docker Compose CLI Reference](https://docs.docker.com/compose/reference/)

### 3.3 Build Verification

After `make up`, verify the build succeeded:

```bash
# Check all containers are running
make status

# Expected output:
# CONTAINER ID   IMAGE       STATUS         PORTS                  NAMES
# xxx            nginx       Up X minutes   0.0.0.0:443->443/tcp   nginx
# xxx            wordpress   Up X minutes                          wordpress
# xxx            mariadb     Up X minutes                          mariadb

# Check for build errors in logs
make logs
```

### 3.4 Rebuilding Individual Services

```bash
# Rebuild a specific service
docker compose -f ./srcs/requirements/docker-compose.yml build nginx
docker compose -f ./srcs/requirements/docker-compose.yml up -d nginx

# Force rebuild without cache
docker compose -f ./srcs/requirements/docker-compose.yml build --no-cache mariadb
```

**Source**: [Docker Compose Build](https://docs.docker.com/compose/reference/build/)

---

## 4. Container and Volume Management

### 4.1 Container Commands

**Accessing containers:**
```bash
# Interactive shell access
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash

# Run a single command
docker exec wordpress wp --info --allow-root
docker exec mariadb mysqladmin -u root -p status
```

**Container lifecycle:**
```bash
# Restart a specific container
docker restart nginx

# View container resource usage
docker stats

# Inspect container configuration
docker inspect nginx
docker inspect wordpress
docker inspect mariadb
```

**Source**: [Docker exec command](https://docs.docker.com/engine/reference/commandline/exec/)

### 4.2 Log Management

```bash
# View logs for all services
make logs

# View logs for a specific service
docker logs nginx
docker logs wordpress
docker logs mariadb

# Follow logs in real-time
docker logs -f wordpress

# View last N lines
docker logs --tail 100 mariadb

# View logs with timestamps
docker logs -t nginx
```

**Source**: [Docker logs command](https://docs.docker.com/engine/reference/commandline/logs/)

### 4.3 Volume Management

**List volumes:**
```bash
docker volume ls

# Output:
# DRIVER    VOLUME NAME
# local     srcs_mariadb
# local     srcs_wordpress
```

**Inspect volume details:**
```bash
docker volume inspect srcs_mariadb
docker volume inspect srcs_wordpress
```

**Volume data locations:**
```
Host Path                          → Container Path
/home/dbhujoo/data/mariadb         → /var/lib/mysql
/home/dbhujoo/data/wordpress       → /var/www/wordpress
```

**Backup volumes:**
```bash
# Backup MariaDB data
sudo tar -czvf mariadb_backup.tar.gz /home/dbhujoo/data/mariadb

# Backup WordPress files
sudo tar -czvf wordpress_backup.tar.gz /home/dbhujoo/data/wordpress
```

**Source**: [Docker Volumes](https://docs.docker.com/storage/volumes/)

### 4.4 Network Management

```bash
# List networks
docker network ls

# Inspect inception network
docker network inspect srcs_inception

# View connected containers
docker network inspect srcs_inception --format '{{range .Containers}}{{.Name}} {{end}}'
```

**Network configuration:**
```yaml
# From docker-compose.yml
networks:
  inception:
    driver: bridge    # Creates isolated network
```

**Source**: [Docker Networking](https://docs.docker.com/network/)

### 4.5 Cleanup Commands

```bash
# Stop all containers
make down

# Remove unused Docker resources
make clean
# Equivalent: docker system prune -af

# Full cleanup (DANGER: deletes all data)
make fclean

# Manual cleanup commands
docker container prune    # Remove stopped containers
docker image prune -a     # Remove unused images
docker volume prune       # Remove unused volumes
docker network prune      # Remove unused networks
```

**Source**: [Docker system prune](https://docs.docker.com/engine/reference/commandline/system_prune/)

---

## 5. Data Storage and Persistence

### 5.1 Data Persistence Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DATA PERSISTENCE                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────┐      ┌─────────────────────┐       │
│  │     MariaDB         │      │     WordPress       │       │
│  │     Container       │      │     Container       │       │
│  │                     │      │                     │       │
│  │  /var/lib/mysql     │      │  /var/www/wordpress │       │
│  └──────────┬──────────┘      └──────────┬──────────┘       │
│             │                            │                   │
│             │ bind mount                 │ bind mount        │
│             ▼                            ▼                   │
│  ┌─────────────────────┐      ┌─────────────────────┐       │
│  │ /home/dbhujoo/data/ │      │ /home/dbhujoo/data/ │       │
│  │ mariadb/            │      │ wordpress/          │       │
│  │                     │      │                     │       │
│  │ • Database files    │      │ • wp-content/       │       │
│  │ • ib_logfile*       │      │ • wp-config.php     │       │
│  │ • wordpress/        │      │ • Themes & Plugins  │       │
│  └─────────────────────┘      └─────────────────────┘       │
│                                                              │
│  PERSISTS AFTER: container stop, restart, rebuild            │
│  DELETED BY: make fclean                                     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Volume Configuration (docker-compose.yml)

```yaml
volumes:
  mariadb:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/dbhujoo/data/mariadb
  wordpress:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/dbhujoo/data/wordpress
```

**Why bind mounts over named volumes?**
- Direct host filesystem access for debugging
- Easy backup/restore operations
- Required by 42 project specifications
- Better visibility into stored data

**Source**: [Docker Storage Overview](https://docs.docker.com/storage/)

### 5.3 What Data Persists?

**MariaDB (`/home/dbhujoo/data/mariadb/`):**
```
mariadb/
├── aria_log.00000001     # Aria storage engine log
├── aria_log_control      # Aria log control file
├── ib_buffer_pool        # InnoDB buffer pool dump
├── ibdata1               # InnoDB system tablespace
├── ib_logfile0           # InnoDB redo log
├── mysql/                # MySQL system database
├── performance_schema/   # Performance schema
└── wordpress/            # WordPress database
    └── *.ibd             # InnoDB table files
```

**WordPress (`/home/dbhujoo/data/wordpress/`):**
```
wordpress/
├── wp-admin/             # WordPress admin files
├── wp-content/           # User content (themes, plugins, uploads)
│   ├── plugins/
│   ├── themes/
│   └── uploads/
├── wp-includes/          # WordPress core includes
├── wp-config.php         # WordPress configuration
├── index.php             # Main entry point
└── ...
```

### 5.4 Data Lifecycle

| Action | MariaDB Data | WordPress Data | Recovery |
|--------|-------------|----------------|----------|
| `docker stop` | ✅ Preserved | ✅ Preserved | `docker start` |
| `make down` | ✅ Preserved | ✅ Preserved | `make up` |
| `make clean` | ✅ Preserved | ✅ Preserved | `make up` |
| `make fclean` | ❌ **Deleted** | ❌ **Deleted** | Restore from backup |
| Host reboot | ✅ Preserved | ✅ Preserved | `make up` |

### 5.5 Backup and Restore

**Database backup:**
```bash
# Export database
docker exec mariadb mysqldump -u root -p$(cat secrets/db_root_password.txt) wordpress > backup.sql

# Restore database
docker exec -i mariadb mysql -u root -p$(cat secrets/db_root_password.txt) wordpress < backup.sql
```

**Full data backup:**
```bash
# Stop services first for consistency
make stop

# Backup
sudo tar -czvf inception_backup_$(date +%Y%m%d).tar.gz /home/dbhujoo/data/

# Restart services
make start
```

**Source**: [MariaDB Backup and Restore](https://mariadb.com/kb/en/backup-and-restore-overview/)

---

## 6. Configuration Files Reference

### 6.1 Docker Compose Configuration

**File**: `srcs/docker_compose.yml`

```yaml
version: '3.8'

services:
  mariadb:
    build:
      context: requirements/mariadb
      dockerfile: Dockerfile
    container_name: mariadb
    networks:
      - inception
    restart: on-failure         # Auto-restart on crash
    env_file: ../.env           # Load environment variables
    secrets:
      - db_password
      - db_root_password
    volumes:
      - mariadb:/var/lib/mysql  # Persistent database storage

  nginx:
    build:
      context: requirements/nginx
      dockerfile: Dockerfile
    container_name: nginx
    networks:
      - inception
    restart: on-failure
    env_file: ../.env
    volumes:
      - wordpress:/var/www/wordpress  # Share WordPress files
    depends_on:
      - wordpress               # Wait for WordPress
    ports:
      - "443:443"              # HTTPS only

  wordpress:
    build:
      context: requirements/wordpress
      dockerfile: Dockerfile
    container_name: wordpress
    networks:
      - inception
    restart: on-failure
    env_file: ../.env
    volumes:
      - wordpress:/var/www/wordpress
    depends_on:
      - mariadb                # Wait for database
    secrets:
      - db_password
      - wp_admin_password
      - wp_user_password
```

**Source**: [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)

### 6.2 Dockerfile Analysis

**MariaDB Dockerfile:**
```dockerfile
FROM debian:bookworm                    # Base image (penultimate stable)

RUN apt update -y \
    && apt upgrade -y \
    && apt-get install mariadb-server -y \
    && rm -rf /var/lib/apt/lists/*      # Clean apt cache

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 3306                             # Document MariaDB port

ENTRYPOINT ["/bin/sh", "/script.sh"]    # Run init script
```

**WordPress Dockerfile:**
```dockerfile
FROM debian:bookworm

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
        wget \
        php8.2 \
        php8.2-fpm \
        php8.2-mysql \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://wordpress.org/wordpress-6.7.1.tar.gz -P /var/www \
    && cd /var/www && tar -xzf wordpress-6.7.1.tar.gz && rm wordpress-6.7.1.tar.gz \
    && chown -R www-data:www-data /var/www/wordpress \
    && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

EXPOSE 9000                             # PHP-FPM port

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/script.sh /

RUN chmod +x /script.sh

CMD ["/script.sh"]
```

**NGINX Dockerfile:**
```dockerfile
FROM debian:bookworm

RUN apt-get update -y \
 && apt-get upgrade -y \
 && apt-get install nginx -y \
 && apt-get install openssl -y \
 && mkdir -p /etc/nginx/ssl \
 && openssl req -x509 -nodes \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=dbhujoo.42.fr/UID=dbhujoo" \
 && mkdir -p /var/run/nginx \
 && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]      # Run in foreground (PID 1)
```

**Source**: [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### 6.3 NGINX Configuration

**File**: `srcs/requirements/nginx/conf/nginx.conf`

Key configuration points:
- TLS 1.2 and 1.3 only (`ssl_protocols TLSv1.2 TLSv1.3;`)
- Self-signed SSL certificate
- Reverse proxy to PHP-FPM on port 9000
- WordPress root at `/var/www/wordpress`

**Source**: [NGINX Configuration Guide](https://nginx.org/en/docs/beginners_guide.html)

### 6.4 PHP-FPM Configuration

**File**: `srcs/requirements/wordpress/conf/www.conf`

Key settings:
- Listen on port 9000 (for NGINX communication)
- Process manager: dynamic
- User/Group: www-data

**Source**: [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.configuration.php)

---

## 7. Debugging and Development

### 7.1 Common Debug Commands

```bash
# Check container status
docker ps -a

# View container logs
docker logs nginx 2>&1 | tail -50
docker logs wordpress 2>&1 | tail -50
docker logs mariadb 2>&1 | tail -50

# Check container health
docker inspect --format='{{.State.Health.Status}}' nginx

# View real-time resource usage
docker stats --no-stream

# Inspect network connectivity
docker exec wordpress ping mariadb
docker exec nginx ping wordpress
```

### 7.2 Database Debugging

```bash
# Connect to MariaDB
docker exec -it mariadb mysql -u root -p

# Useful MySQL commands
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT user, host FROM mysql.user;
```

### 7.3 WordPress Debugging

```bash
# Access WordPress container
docker exec -it wordpress bash

# WP-CLI commands
wp --info --allow-root
wp core is-installed --allow-root
wp user list --allow-root
wp plugin list --allow-root

# Check PHP-FPM status
ps aux | grep php-fpm
```

### 7.4 NGINX Debugging

```bash
# Test NGINX configuration
docker exec nginx nginx -t

# Check NGINX processes
docker exec nginx ps aux | grep nginx

# View access/error logs
docker exec nginx tail -f /var/log/nginx/access.log
docker exec nginx tail -f /var/log/nginx/error.log
```

### 7.5 Redis Debugging

```bash
# Check Redis status from WordPress
docker exec -it wordpress wp redis status --allow-root --path='/var/www/wordpress'

# Connect to Redis CLI
docker exec -it redis redis-cli

# Useful Redis commands
PING                    # Should return PONG
INFO                    # Server information
INFO memory             # Memory usage
DBSIZE                  # Number of keys in database
KEYS *                  # List all keys (use with caution)
FLUSHALL                # Clear all data (use with caution)

# Monitor Redis in real-time
docker exec -it redis redis-cli MONITOR

# Check Redis logs
docker logs redis 2>&1 | tail -50

# Test connectivity from WordPress
docker exec wordpress redis-cli -h redis ping
```

### 7.6 Network Debugging

```bash
# Test HTTPS connection
curl -k https://dbhujoo.42.fr

# Check open ports
docker exec nginx netstat -tlnp
docker exec wordpress netstat -tlnp

# DNS resolution inside containers
docker exec wordpress getent hosts mariadb
```

### 7.7 Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Container keeps restarting | Script error or misconfiguration | `docker logs <container>` |
| Cannot connect to database | MariaDB not ready | Check `depends_on` and wait logic |
| 502 Bad Gateway | PHP-FPM not running | `docker restart wordpress` |
| SSL certificate error | Self-signed certificate | Accept in browser (expected) |
| Permission denied | Volume ownership | `chown -R www-data:www-data` |
| Port already in use | Another service on 443 | `sudo lsof -i :443` |
| Redis not connected | Redis container not running | `docker restart redis` |
| Redis cache not working | Plugin not enabled | `wp redis enable --allow-root` |

---

## 8. References

### 8.1 Official Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [WP-CLI Documentation](https://wp-cli.org/)
- [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php)
- [Redis Documentation](https://redis.io/documentation)
- [Redis Object Cache Plugin](https://wordpress.org/plugins/redis-cache/)

### 8.2 Best Practices

- [Docker Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [The Twelve-Factor App](https://12factor.net/)

### 8.3 Troubleshooting Resources

- [Docker Compose Troubleshooting](https://docs.docker.com/compose/troubleshooting/)
- [NGINX Debugging](https://nginx.org/en/docs/debugging_log.html)
- [MariaDB Troubleshooting](https://mariadb.com/kb/en/troubleshooting/)

---

*Document created on January 29, 2026 by dbhujoo*  
*Inception Project - 42 School*