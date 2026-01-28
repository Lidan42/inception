*This project has been created as part of the 42 curriculum by dbhujoo*

## Description

**Inception** is a system administration and Docker containerization project that focuses on building a complete web infrastructure using Docker containers. The goal is to set up a small infrastructure composed of different services following specific rules and best practices.

This project demonstrates the ability to:
- Virtualize multiple Docker containers in a personal virtual machine
- Configure each service to run in dedicated containers
- Implement proper networking and volume management
- Ensure security through environment variables and secrets management
- Build custom Docker images from scratch (using penultimate stable versions)

The infrastructure includes:
- **NGINX** with TLSv1.2 or TLSv1.3 only
- **WordPress** with php-fpm (without nginx)
- **MariaDB** database
- Persistent volumes for database and website files
- A docker network for inter-container communication

**Instructions**

section containing any relevant information about compilation,
installation, and/or execution.




**Resources**

section listing classic references related to the topic (documen-
tation, articles, tutorials, etc.), as well as a description of how AI was used —
specifying for which tasks and which parts of the project.

Additional sections may be required depending on the project (e.g., usage
examples, feature list, technical choices, etc.).


***1 - Docker definiton : ***

*“Docker is an open platform for developing, shipping, and running applications.Docker enables you to separate your applications from your infrastructure so you can deliver software quickly. With Docker, you can manage your infrastructure in the same ways you manage your applications. By taking advantage of Docker's methodologies for shipping, testing, and deploying code, you can significantly reduce the delay between writing code and running it in production”*
*link : https://docs.docker.com/get-started/overview/*


***AI use :***

In this project, AI was firstly use to search documentation about dockers : their use, their definition, understand the subject to be able to create a plan in order to start the inception project.




**Project description**

section must also explain the use of Docker and the sources
included in the project. It must indicate the main design choices, as well as a
comparison between:

***1 - Use of a docker :***

L’objectif principal est **la portabilité, la reproductibilité et la simplification du déploiement d'une application** (faire tourner une application, avec le bon environnement, sur une autre machine que celle où elle a été développée, sans la reconfigurer manuellement.)

*"Docker streamlines the development lifecycle by allowing developers to work in standardized environments using local containers which provide your applications and services. Containers are great for continuous integration and continuous delivery (CI/CD) workflows."*
*"Consider the following example scenario:"*
*"Your developers write code locally and share their work with their colleagues using Docker containers."*
*"They use Docker to push their applications into a test environment and run automated and manual tests."*
*"When developers find bugs, they can fix them in the development environment and redeploy them to the test environment for testing and validation."*
*"When testing is complete, getting the fix to the customer is as simple as pushing the updated image to the production environment."*
*link : https://docs.docker.com/get-started/overview/*

“Docker simplifies deployment by allowing developers to deploy applications quickly and consistently.”
link : https://aws.amazon.com/docker/

Avant Docker (déploiement “classique”)
configuration manuelle des serveurs
dépendances incompatibles
différences entre dev / prod
erreurs humaines

Avec Docker
copier une image
lancer un conteneur

***2 - NGINX definition:***

NGINX is an open-source server software primarily used as a web server and reverse proxy.

NGINX is a program that runs on a server and handles receiving requests from clients (browsers, APIs, etc.) and responding to them appropriately.

**How it works:**

When you type a URL in your browser:
1. The browser sends an HTTP request
2. NGINX receives this request
3. NGINX decides what to do:
   - Return a file (HTML, CSS, image, etc.)
   - Forward the request to an application (PHP, Node.js, Python, etc.)
   - Redirect to another server

**Load Balancing:**

NGINX can distribute requests across multiple servers.

Objectives:
- Prevent server overload
- Improve availability

**Key Features:**

- High performance
- Low memory consumption
- Asynchronous/event-driven architecture
- Widely used in production environments (high-traffic websites)

**TLS Protocol:**

TLSv1.2 and TLSv1.3

These are two versions of the TLS protocol:

| Version | Year | Key Features |
|---------|------|--------------|
| TLS 1.2 | 2008 | - Strong but slower encryption<br>- Complex key negotiation<br>- Supports many legacy algorithms |
| TLS 1.3 | 2018 | - Faster and more secure<br>- Fewer legacy algorithms<br>- Simplified key exchange (faster handshake)<br>- Forward Secrecy enabled by default |

***3 - MARIADB definition:***

MariaDB is an open-source Relational DataBase Management System (RDBMS) that is a fork of MySQL.

MariaDB is designed to store, organize, and retrieve data efficiently. It uses SQL (Structured Query Language) to manage and query data stored in tables.

**How it works:**

When an application needs to store or retrieve data:
1. The application sends SQL queries to MariaDB
2. MariaDB processes the query (INSERT, SELECT, UPDATE, DELETE)
3. MariaDB returns the requested data or confirmation of the operation

**Key Features:**

- High performance and scalability
- ACID compliance (Atomicity, Consistency, Isolation, Durability)
- Support for multiple storage engines (InnoDB, Aria, etc.)
- Compatible with MySQL (drop-in replacement)
- Active community and regular updates
- Advanced security features (user authentication, encryption, SSL/TLS)

**Common Use Cases:**

- Web applications (WordPress, Drupal, etc.)
- E-commerce platforms
- Content management systems
- Data warehousing
- Analytics and reporting

**Why MariaDB over MySQL:**

- Fully open-source (no proprietary modules)
- Better performance in many scenarios
- More storage engines available
- Active development and faster release cycle
- Community-driven development

***4 - WORDPRESS definition:***

WordPress is an open-source Content Management System (CMS) written in PHP and paired with a MySQL or MariaDB database.

WordPress is the most popular website builder in the world, powering over 40% of all websites. It allows users to create and manage websites without extensive coding knowledge.

**How it works:**

WordPress architecture consists of three main components:
1. **PHP-FPM** processes PHP code and generates dynamic content
2. **MariaDB/MySQL** stores all website data (posts, users, settings)
3. **Web Server (NGINX)** serves static files and forwards PHP requests to PHP-FPM

**WordPress with PHP-FPM:**

PHP-FPM (FastCGI Process Manager) is a preferred way to run PHP:
- Separates PHP processing from the web server
- Better performance and resource management
- Allows independent scaling of PHP and web server
- Communicates via TCP (port 9000) or Unix socket

**Key Features:**

- Intuitive admin dashboard
- Extensive plugin ecosystem (60,000+ plugins)
- Thousands of themes for customization
- Built-in user management and roles
- SEO-friendly structure
- Multi-language support
- RESTful API for headless implementations

**Common Use Cases:**

- Blogs and personal websites
- Business and corporate websites
- E-commerce (with WooCommerce)
- Portfolios and galleries
- News and magazine sites
- Community forums and membership sites

**Why WordPress:**

- Free and open-source
- Easy to install and configure
- Large community and extensive documentation
- Regular security updates
- Flexible and highly customizable
- No coding required for basic usage

**WP-CLI:**

WordPress Command Line Interface allows:
- Automated installation and configuration
- Plugin and theme management via scripts
- Database operations without web interface
- Perfect for Docker containerization

***◦ Virtual Machines vs Docker***

Une machine virtuelle :
- virtualise le matériel
- embarque un système d’exploitation complet (kernel + userland)
- est plus lourde en ressources (RAM, CPU, stockage)

“Virtual machines include a full copy of an operating system, one or more apps, necessary binaries and libraries.”

Lien : https://docs.docker.com/get-started/overview/#containers-and-virtual-machines

Un conteneur Docker :
-virtualise le système d’exploitation, pas le matériel
-partage le noyau de l’OS hôte
-n’embarque que l’application et ses dépendances
-est plus léger et plus rapide à démarrer

“Containers share the host system’s kernel and isolate the application processes from the rest of the system.”
Lien : https://docs.docker.com/get-started/overview/

Synthetic comparison :
 -------------------------------------------------------------------------
| Criteria       | Virtual Machines        | Docker                       |
| -------------- | ----------------------- | ---------------------------- |
| Virtualisation | Matériel                | OS                           |
| OS embarqué    | Oui                     | Non                          |
| Poids          | Élevé                   | Léger                        |
| Démarrage      | Lent (secondes/minutes) | Très rapide (ms/s)           |
| Isolation      | Forte                   | Suffisante pour l’applicatif |
 -------------------------------------------------------------------------


***◦ Secrets vs Environment Variables***

**Environment Variables:**

Environment variables are key-value pairs passed to containers at runtime to configure application behavior.

How they work:
- Defined in `docker-compose.yml` or Dockerfile
- Accessible within the container as system environment variables
- Visible in container inspection (`docker inspect`)

```yaml
environment:
  - DB_NAME=wordpress
  - DB_USER=admin
```

**Docker Secrets:**

Secrets are encrypted data managed by Docker Swarm or external secret managers for sensitive information.

How they work:
- Encrypted at rest and in transit
- Only accessible to authorized services
- Mounted as files in `/run/secrets/`
- Not visible in environment variables or logs

```yaml
secrets:
  - db_password
```

**Comparison:**

| Criteria | Environment Variables | Docker Secrets |
|----------|----------------------|----------------|
| Security | Visible in logs/inspect | Encrypted and protected |
| Use case | Non-sensitive config | Passwords, keys, tokens |
| Storage | Plain text | Encrypted |
| Access | Environment vars | Files in /run/secrets/ |
| Best for | Development | Production |

**Best Practices:**
- Use environment variables for non-sensitive configuration
- Use secrets for passwords, API keys, certificates
- Never commit secrets to version control
- Use `.env` files (gitignored) for local development

***◦ Docker Network vs Host Network***

**Docker Network (Bridge):**

Creates an isolated virtual network for containers to communicate with each other.

How it works:
- Each container gets its own IP address
- Containers communicate via container names (DNS resolution)
- Isolated from host network
- Port mapping required to expose services

```yaml
networks:
  inception:
    driver: bridge
```

**Host Network:**

Container shares the host's network stack directly.

How it works:
- No network isolation
- Container uses host's IP address
- Direct access to host network interfaces
- No port mapping needed

```yaml
network_mode: host
```

**Comparison:**

| Criteria       | Docker Network        | Host Network          |
|----------      |---------------        |--------------         |
| Isolation      | Yes (isolated)        | No (shared with host) |
| Performance    | Slight overhead       | Native performance    |
| Port conflicts | Avoided (mapping)     | Possible              |
| Security       | Better (isolation)    | Lower (direct access) |
| DNS resolution | Yes (container names) | No                    |
| Best for       | Multi-container apps  | Performance-critical  |

**For Inception:**
- Use Docker bridge network for container communication
- NGINX communicates with WordPress via network name
- Better security through isolation

***◦ Docker Volumes vs Bind Mounts***

**Docker Volumes:**

Managed storage created and managed by Docker, stored in Docker's storage directory.

How they work:
- Created with `docker volume create` or automatically
- Stored in `/var/lib/docker/volumes/`
- Managed entirely by Docker
- Persistent across container lifecycle

```yaml
volumes:
  db_data:
    driver: local
```

**Bind Mounts:**

Direct mapping of host filesystem directories into containers.

How they work:
- Maps specific host path to container path
- Full host filesystem access
- Host directory must exist
- Changes reflect immediately on both sides

```yaml
volumes:
  - /host/path:/container/path
```

**Comparison:**

| Criteria | Docker Volumes | Bind Mounts |
|----------|---------------|-------------|
| Management | Docker-managed | User-managed |
| Location | Docker directory | Any host path |
| Portability | High (Docker-aware) | Low (path-dependent) |
| Performance | Optimized | Native |
| Backup | Docker tools | Manual |
| Permissions | Docker handles | Host permissions |
| Best for | Production data | Development/config files |

**For Inception:**
- Use Docker volumes for database data (persistent)
- Use Docker volumes for WordPress files
- Ensures data persists even if containers are removed
- Better portability and management

**Volume Example:**
```yaml
services:
  mariadb:
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
    driver: local
```