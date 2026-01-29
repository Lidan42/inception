*This project has been created as part of the 42 curriculum by dbhujoo*

---

# Inception

A Docker-based web infrastructure project implementing a complete LEMP stack with security best practices.

---

## Table of Contents

1. [Description](#description)
2. [Features](#features)
3. [Instructions](#instructions)
4. [Project Description](#project-description)
5. [Technical Choices & Comparisons](#technical-choices--comparisons)
6. [Resources](#resources)
7. [AI Usage Declaration](#ai-usage-declaration)

---

## Description

**Inception** is a system administration and Docker containerization project that focuses on building a complete web infrastructure using Docker containers within a virtual machine environment.

### Project Goal

The main objective is to set up a small but complete infrastructure composed of different services following specific rules and best practices:

- **NGINX** container with TLSv1.2/TLSv1.3 only (serves as the single entry point via port 443)
- **WordPress** container with PHP-FPM (without NGINX)
- **MariaDB** container for database management
- **Docker network** for secure inter-container communication
- **Docker volumes** for persistent data storage

### Key Learning Objectives

This project demonstrates proficiency in:

| Area                 | Skills Acquired                                              |
|----------------------|--------------------------------------------------------------|
| **Containerization** | Building custom Docker images from Debian base               |
| **Networking**       | Configuring isolated Docker networks for secure communication|
| **Security**         | Implementing TLS, secrets management, and proper isolation   |
| **Infrastructure**   | Setting up a complete web stack from scratch                 |
| **Automation**       | Using Makefile for build automation and orchestration        |

**Source**: [Docker Overview](https://docs.docker.com/get-started/overview/)

---

## Features

### Infrastructure Components

```
┌─────────────────────────────────────────────────────────────────┐
│                         HOST MACHINE                             │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                Docker Network: inception                    │ │
│  │                                                             │ │
│  │   ┌──────────┐     ┌─────────────┐     ┌──────────────┐   │ │
│  │   │  NGINX   │────▶│  WordPress  │────▶│   MariaDB    │   │ │
│  │   │  :443    │ PHP │  :9000      │ SQL │   :3306      │   │ │
│  │   │  TLS 1.3 │ FPM │  PHP-FPM    │     │              │   │ │
│  │   └────┬─────┘     └──────┬──────┘     └──────┬───────┘   │ │
│  │        │                  │                   │            │ │
│  └────────┼──────────────────┼───────────────────┼────────────┘ │
│           │                  │                   │              │
│           ▼                  ▼                   ▼              │
│   ┌───────────────────────────────────────────────────────────┐ │
│   │                    Persistent Volumes                      │ │
│   │   /home/dbhujoo/data/wordpress    /home/dbhujoo/data/mariadb │
│   └───────────────────────────────────────────────────────────┘ │
│                              │                                   │
└──────────────────────────────┼───────────────────────────────────┘
                               │
                        Port 443 (HTTPS)
                               │
                               ▼
                         Client Browser
```

### Service Details

| Service       | Base Image      | Port | Role                           |
|---------------|-----------------|------|--------------------------------|
| **NGINX**     | debian:bookworm | 443  | Reverse proxy, TLS termination |
| **WordPress** | debian:bookworm | 9000 | PHP-FPM, CMS application       |
| **MariaDB**   | debian:bookworm | 3306 | Relational database            |

### Security Features

- ✅ TLSv1.2 and TLSv1.3 only (no deprecated protocols)
- ✅ Self-signed SSL certificates
- ✅ Docker secrets for sensitive data
- ✅ Isolated Docker network
- ✅ No root process in containers (where applicable)
- ✅ Minimal base images with security updates

---

## Instructions

### Prerequisites

| Requirement      | Minimum Version | Installation                                     |
|------------------|-----------------|--------------------------------------------------|
| Docker Engine    | 20.10+          | [Get Docker](https://docs.docker.com/get-docker/)|
| Docker Compose   | 2.0+            | Included with Docker Desktop                     |
| Make             | 4.0+            | `apt install make`                               |
| Git              | 2.0+            | `apt install git`                                |

**Verify installation:**
```bash
docker --version          # Docker version 24.0.0+
docker compose version    # Docker Compose version v2.20.0+
make --version           # GNU Make 4.3+
```

### Installation

**1. Clone the repository:**
```bash
git clone <repository-url> inception
cd inception
```

**2. Configure local domain:**
```bash
echo "127.0.0.1    dbhujoo.42.fr" | sudo tee -a /etc/hosts
```

**3. Create data directories:**
```bash
sudo mkdir -p /home/dbhujoo/data/mariadb
sudo mkdir -p /home/dbhujoo/data/wordpress
sudo chown -R $USER:$USER /home/dbhujoo/data
```

**4. Configure secrets:**
```bash
# Edit secret files with secure passwords
nano secrets/db_password.txt
nano secrets/db_root_password.txt
nano secrets/wp_admin_password.txt
nano secrets/wp_user_password.txt

# Set permissions
chmod 600 secrets/*.txt
```

**5. Configure environment variables:**
```bash
# Create .env file (see .env.example)
cp .env.example .env
nano .env
```

### Building and Running

| Command       | Description                          |
|---------------|--------------------------------------|
| `make up`     | Build images and start all services  |
| `make down`   | Stop and remove all containers       |
| `make stop`   | Stop containers (preserve state)     |
| `make start`  | Start stopped containers             |
| `make re`     | Rebuild and restart all services     |
| `make clean`  | Remove containers and prune Docker   |
| `make fclean` | Full clean including data volumes    |
| `make status` | Show running containers              |
| `make logs`   | Follow container logs                |

**Quick start:**
```bash
make up
```

**Access the website:**
- **Site**: https://dbhujoo.42.fr
- **Admin**: https://dbhujoo.42.fr/wp-admin

### Verification

```bash
# Check containers are running
make status

# Test HTTPS connection
curl -k https://dbhujoo.42.fr

# Check logs for errors
make logs
```

---

## Project Description

### What is Docker?

> *"Docker is an open platform for developing, shipping, and running applications. Docker enables you to separate your applications from your infrastructure so you can deliver software quickly."*  
> — [Docker Documentation](https://docs.docker.com/get-started/overview/)

Docker is a containerization platform that packages applications and their dependencies into isolated containers. Unlike virtual machines, containers share the host OS kernel, making them lightweight and fast to start.

**Key benefits for this project:**
- **Portability**: Same environment across development and production
- **Isolation**: Each service runs in its own container
- **Reproducibility**: Infrastructure as code via Dockerfiles
- **Efficiency**: Lightweight compared to full VMs

### Architecture Decisions

This project implements the following architecture:

1. **Debian Bookworm** as base image (penultimate stable version as required)
2. **Custom Dockerfiles** for each service (no pre-built images)
3. **Docker Compose** for orchestration
4. **Bridge network** for secure inter-container communication
5. **Bind mount volumes** for data persistence
6. **Docker secrets** for sensitive credentials

### Service Descriptions

#### NGINX (Web Server & Reverse Proxy)

NGINX serves as the single entry point to the infrastructure:

- Handles all incoming HTTPS requests on port 443
- Terminates TLS connections (TLSv1.2/1.3 only)
- Proxies PHP requests to WordPress via FastCGI
- Serves static files directly

**Source**: [NGINX Documentation](https://nginx.org/en/docs/)

#### WordPress (CMS with PHP-FPM)

WordPress runs with PHP-FPM for optimal performance:

- PHP-FPM listens on port 9000
- Processes dynamic PHP content
- Connects to MariaDB for data storage
- WP-CLI for automated setup

**Source**: [WordPress Developer Resources](https://developer.wordpress.org/)

#### MariaDB (Database)

MariaDB stores all WordPress data:

- Relational database management
- Persistent storage via Docker volumes
- Initialized via startup script
- Secured with root and user passwords

**Source**: [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)

---

## Technical Choices & Comparisons

### Virtual Machines vs Docker

| Criteria           | Virtual Machines               | Docker Containers                |
|--------------------|--------------------------------|----------------------------------|
| **Virtualization** | Hardware-level (hypervisor)    | OS-level (kernel sharing)        |
| **OS**             | Full guest OS per VM           | Shares host kernel               |
| **Size**           | Gigabytes (full OS)            | Megabytes (app + deps only)      |
| **Startup Time**   | Minutes                        | Seconds/milliseconds             |
| **Resource Usage** | High (dedicated resources)     | Low (shared resources)           |
| **Isolation**      | Strong (hardware-level)        | Process-level (sufficient)       |
| **Portability**    | Limited (hypervisor-dependent) | High (runs anywhere Docker runs) |

**Why Docker for Inception:**
- Faster development cycles
- Lower resource footprint
- Easier orchestration of multiple services
- Better suited for microservices architecture

> *"Containers share the host system's kernel and isolate the application processes from the rest of the system."*  
> — [Docker Documentation](https://docs.docker.com/get-started/overview/)

**Source**: [Containers vs VMs](https://www.docker.com/resources/what-container/)

---

### Secrets vs Environment Variables

| Criteria          | Environment Variables          | Docker Secrets                    |
|-------------------|--------------------------------|-----------------------------------|
| **Security**      | Visible in logs, inspect, ps   | Encrypted at rest and in transit  |
| **Storage**       | Plain text in memory           | Encrypted files                   |
| **Access**        | `$ENV_VAR`                     | `/run/secrets/secret_name`        |
| **Visibility**    | Exposed in container metadata  | Hidden from inspection            |
| **Use Case**      | Non-sensitive configuration    | Passwords, API keys, certificates |
| **Best Practice** | Development only               | Production environments           |

**Implementation in Inception:**
```yaml
# Environment variables for non-sensitive data
env_file: ../.env

# Secrets for sensitive data
secrets:
  - db_password
  - db_root_password
```

**Why both:**
- Environment variables: Database name, WordPress URL, user names
- Secrets: All passwords and sensitive credentials

> *"In terms of Docker Swarm services, a secret is a blob of data that should not be transmitted over a network or stored unencrypted."*  
> — [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)

---

### Docker Network vs Host Network

| Criteria            | Docker Bridge Network       | Host Network              |
|---------------------|-----------------------------|--------------------------|
| **Isolation**       | Isolated virtual network    | Shares host network stack |
| **IP Address**      | Container gets own IP       | Uses host IP              |
| **DNS**             | Automatic (container names) | No internal DNS           |
| **Port Conflicts**  | Avoided via port mapping    | Possible with host services|
| **Security**        | Better (isolated)           | Lower (direct access)     |
| **Performance**     | Slight overhead             | Native performance        |
| **Multi-container** | Easy communication          | Complex setup             |

**Implementation in Inception:**
```yaml
networks:
  inception:
    driver: bridge
```

**Why Bridge Network:**
- Containers communicate via service names (`mariadb`, `wordpress`)
- Isolation from host network
- Only port 443 exposed to outside world
- Better security posture

> *"Bridge networks are commonly used when your application runs in a container that needs to communicate with other containers on the same host."*  
> — [Docker Networking](https://docs.docker.com/network/bridge/)

---

### Docker Volumes vs Bind Mounts

| Criteria        | Docker Volumes               | Bind Mounts                   |
|-----------------|------------------------------|-------------------------------|
| **Management**  | Docker-managed               | User-managed                  |
| **Location**    | `/var/lib/docker/volumes/`   | Any host path                 |
| **Creation**    | Automatic or manual          | Directory must exist          |
| **Portability** | High (Docker handles)        | Low (path-dependent)          |
| **Backup**      | Docker CLI tools             | Manual file operations        |
| **Performance** | Optimized for containers     | Native filesystem             |
| **Permissions** | Docker manages               | Host filesystem permissions   |
| **Visibility**  | Abstracted                   | Direct host access            |

**Implementation in Inception (Bind Mounts with Volume syntax):**
```yaml
volumes:
  mariadb:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/dbhujoo/data/mariadb
```

**Why Bind Mounts:**
- Required by project specifications
- Direct access to data for debugging
- Easy backup via host filesystem
- Clear data location visibility

> *"Bind mounts have limited functionality compared to volumes. When you use a bind mount, a file or directory on the host machine is mounted into a container."*  
> — [Docker Storage](https://docs.docker.com/storage/bind-mounts/)

---

## Resources

### Official Documentation

| Technology         | Documentation                                                                      |
|--------------------|------------------------------------------------------------------------------------|
| **Docker**         | [docs.docker.com](https://docs.docker.com/)                                        |
| **Docker Compose** | [Compose Documentation](https://docs.docker.com/compose/)                          |
| **NGINX**          | [nginx.org/en/docs](https://nginx.org/en/docs/)                                    |
| **WordPress**      | [developer.wordpress.org](https://developer.wordpress.org/)                        |
| **MariaDB**        | [mariadb.com/kb](https://mariadb.com/kb/en/documentation/)                         |
| **PHP-FPM**        | [php.net/manual/en/install.fpm.php](https://www.php.net/manual/en/install.fpm.php) |
| **WP-CLI**         | [wp-cli.org](https://wp-cli.org/)                                                  |

### Tutorials & Articles

- [Docker Getting Started](https://docs.docker.com/get-started/)
- [Docker Compose Tutorial](https://docs.docker.com/compose/gettingstarted/)
- [NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [Dockerizing WordPress](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose)
- [Docker Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

### Technical Specifications

- [TLS 1.2 - RFC 5246](https://datatracker.ietf.org/doc/html/rfc5246)
- [TLS 1.3 - RFC 8446](https://datatracker.ietf.org/doc/html/rfc8446)
- [FastCGI Specification](https://fastcgi-archives.github.io/FastCGI_Specification.html)

### Best Practices

- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [The Twelve-Factor App](https://12factor.net/)
- [WordPress Security Best Practices](https://wordpress.org/support/article/hardening-wordpress/)

---

## AI Usage Declaration

### How AI Was Used in This Project

AI tools were used during the development of this project for the following purposes:

#### 1. Documentation Research
- Understanding Docker concepts and architecture
- Learning about TLS protocols and security best practices
- Researching NGINX, PHP-FPM, and MariaDB configurations

#### 2. Debugging Assistance
- Resolving network connectivity problems

#### 3. Code Review & Optimization
- Optimizing shell scripts for idempotency

#### 4. Documentation Writing
- Structuring README.md and documentation files
- Creating comparison tables
- Writing clear explanations of technical concepts

### Parts NOT Generated by AI

The following were done entirely manually:
- ✅ Understanding project requirements
- ✅ Architecture design decisions
- ✅ Testing and validation
- ✅ Final code integration
- ✅ Security considerations specific to 42 requirements

### AI Usage Philosophy

AI was used as a **learning accelerator** and **documentation assistant**, not as a code generator. All code was reviewed, understood, and adapted to meet specific project requirements.

> *"AI tools can help developers work more efficiently, but understanding the underlying concepts remains essential for writing secure and maintainable code."*

---

## License

This project is part of the 42 curriculum. All rights reserved.

---

*Document created on January 29, 2026 by dbhujoo*  
*Inception Project - 42 School*
