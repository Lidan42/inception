# 📋 Guide d'Évaluation - Projet Inception

*Fichier préparé pour faciliter l'évaluation du projet*

---

## 📌 Table des Matières

1. [Préliminaires](#1-préliminaires)
2. [Instructions Générales](#2-instructions-générales)
3. [Partie Obligatoire](#3-partie-obligatoire)
4. [Bonus](#4-bonus)
5. [Commandes Utiles](#5-commandes-utiles)

---

## 1. Préliminaires

### ✅ Vérification des credentials/secrets

**Commande :**
```bash
# Vérifier que les secrets ne sont pas dans le repo (hors du dossier secrets/)
grep -r "password" --include="*.yml" --include="*.conf" --include="*.sh" /home/dbhujoo/Desktop/inception/
```

**Réponse attendue :** Les mots de passe ne doivent pas apparaître en clair. Le projet utilise :
- **Docker Secrets** : les fichiers sensibles sont dans `secrets/` et montés via `/run/secrets/`
- Exemple dans `docker_compose.yml` : les secrets sont déclarés proprement
- Les scripts lisent les secrets via `$(cat /run/secrets/db_password)`

✅ **Le projet utilise correctement Docker Secrets**

---

## 2. Instructions Générales

### 2.1 Vérification de la structure du projet

**Commande :**
```bash
ls -la /home/dbhujoo/Desktop/inception/
ls -la /home/dbhujoo/Desktop/inception/srcs/
```

**Éléments à vérifier :**
- ✅ `srcs/` est à la racine du repository
- ✅ `Makefile` est à la racine du repository
- ✅ `docker_compose.yml` est dans `srcs/`

### 2.2 Nettoyage Docker OBLIGATOIRE avant évaluation

**⚠️ EXÉCUTER CETTE COMMANDE AVANT DE COMMENCER :**
```bash
docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null
```

### 2.3 Vérification docker-compose.yml (éléments interdits)

**Commandes de vérification :**
```bash
# Vérifier l'absence de 'network: host'
grep -i "network.*host" /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml
# ✅ Aucun résultat attendu

# Vérifier l'absence de 'links:'
grep -i "links:" /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml
# ✅ Aucun résultat attendu

# Vérifier la présence de 'networks:'
grep -i "networks:" /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml
# ✅ Doit retourner des résultats (réseau 'inception' configuré)
```

### 2.4 Vérification des Dockerfiles et scripts (éléments interdits)

**Commandes :**
```bash
# Vérifier l'absence de '--link'
grep -r "\-\-link" /home/dbhujoo/Desktop/inception/
# ✅ Aucun résultat attendu

# Vérifier l'absence de 'tail -f' ou commandes en background dans ENTRYPOINT
grep -r "tail -f" /home/dbhujoo/Desktop/inception/srcs/requirements/
# ✅ Aucun résultat attendu

# Vérifier l'absence de boucles infinies
grep -rE "sleep infinity|tail -f /dev/null|tail -f /dev/random" /home/dbhujoo/Desktop/inception/
# ✅ Aucun résultat attendu
```

### 2.5 Vérification des images de base (Alpine/Debian penultimate)

**Commande :**
```bash
grep -r "^FROM" /home/dbhujoo/Desktop/inception/srcs/requirements/
```

**Résultat attendu :**
```
requirements/mariadb/Dockerfile:FROM debian:bookworm
requirements/nginx/Dockerfile:FROM debian:bookworm
requirements/wordpress/Dockerfile:FROM debian:bookworm
requirements/bonus/redis/Dockerfile:FROM debian:bookworm
requirements/bonus/ftp/Dockerfile:FROM debian:bookworm
requirements/bonus/adminer/Dockerfile:FROM debian:bookworm
requirements/bonus/cadvisor/Dockerfile:FROM debian:bookworm
requirements/bonus/static-site/Dockerfile:FROM debian:bookworm
```
✅ **Tous les conteneurs utilisent `debian:bookworm` (version stable actuelle)**

### 2.6 Lancement du projet

**Commande :**
```bash
cd /home/dbhujoo/Desktop/inception && make
```

---

## 3. Partie Obligatoire

### 3.1 Vue d'ensemble de l'activité

**Questions à poser et réponses attendues :**

#### 🐳 Comment fonctionne Docker ?

| Aspect          | Explication                                                            |
|:----------------|:-----------------------------------------------------------------------|
| **Principe**    | Docker utilise la conteneurisation pour isoler les applications        |
| **Kernel**      | Contrairement aux VMs, les conteneurs partagent le kernel de l'hôte    |
| **Performance** | Légers et rapides à démarrer                                           |
| **Isolation**   | Chaque conteneur a son propre système de fichiers, réseau et processus |

#### 🔄 Différence entre image Docker avec/sans compose ?

| Sans Compose                              | Avec Compose                                          |
|:------------------------------------------|:------------------------------------------------------|
| Lancement manuel de chaque conteneur      | Définition de tous les services dans un fichier YAML  |
| Commande `docker run` pour chaque service | Une seule commande pour tout orchestrer               |
| Gestion manuelle des dépendances          | Compose gère automatiquement les dépendances          |
| Configuration répétitive                  | Configuration centralisée et réutilisable             |

#### ⚡ Avantage de Docker vs VMs ?

| Critère         | Docker                    | VM                        |
|:----------------|:--------------------------|:--------------------------|
| **Poids**       | Léger (partage du kernel) | Lourd (OS complet)        |
| **Démarrage**   | Secondes                  | Minutes                   |
| **Ressources**  | Faible consommation       | Consommation élevée       |
| **Portabilité** | Excellente via images     | Limitée                   |
| **Isolation**   | Bonne                     | Meilleure mais coûteuse   |

#### 📁 Pertinence de la structure de répertoires ?

| Emplacement                      | Contenu                   | Raison                                |
|:---------------------------------|:--------------------------|:--------------------------------------|
| `/` (racine)                     | `Makefile`                | Point d'entrée unique pour build/run  |
| `/srcs/`                         | `docker_compose.yml`      | Configuration centrale des services   |
| `/srcs/requirements/<service>/`  | `Dockerfile`              | Contexte de build isolé par service   |
| `/secrets/`                      | Fichiers de mots de passe | Séparation des données sensibles      |

### 3.2 Vérification README

**Commande :**
```bash
head -5 /home/dbhujoo/Desktop/inception/README.md
```

**Éléments à vérifier :**
- ✅ Première ligne : `*This project has been created as part of the 42 curriculum by dbhujoo*`
- ✅ Section Description présente
- ✅ Section Instructions présente  
- ✅ Section Resources présente (avec explication sur l'utilisation de l'IA)

### 3.3 Vérification Documentation

**Commandes :**
```bash
# Vérifier présence des fichiers
ls -la /home/dbhujoo/Desktop/inception/USERDOC.md
ls -la /home/dbhujoo/Desktop/inception/DEVDEC.md

# Vérifier le contenu
head -50 /home/dbhujoo/Desktop/inception/USERDOC.md
head -50 /home/dbhujoo/Desktop/inception/DEVDEC.md
```

**Éléments présents :**
- ✅ `USERDOC.md` : Instructions utilisateur (start/stop, accès site, credentials, checks)
- ✅ `DEVDEC.md` : Instructions développeur (prérequis, setup, Makefile, docker compose, persistance)

### 3.4 Simple Setup

**Commandes de vérification :**

```bash
# 1. Vérifier que NGINX n'écoute QUE sur le port 443
docker ps --format "table {{.Names}}\t{{.Ports}}"
# nginx doit montrer : 0.0.0.0:443->443/tcp

# 2. Tester l'accès HTTP (doit échouer)
curl -I http://dbhujoo.42.fr 2>&1
# ✅ Doit retourner une erreur de connexion

# 3. Tester l'accès HTTPS
curl -kI https://dbhujoo.42.fr
# ✅ Doit retourner HTTP 200

# 4. Vérifier le certificat TLS
openssl s_client -connect dbhujoo.42.fr:443 -tls1_2 </dev/null 2>/dev/null | grep -E "Protocol|Cipher"
openssl s_client -connect dbhujoo.42.fr:443 -tls1_3 </dev/null 2>/dev/null | grep -E "Protocol|Cipher"
# ✅ TLSv1.2 ou TLSv1.3 confirmé

# 5. Accéder au site WordPress
# Ouvrir dans un navigateur : https://dbhujoo.42.fr
# ✅ Le site WordPress doit s'afficher (pas la page d'installation)
```

### 3.5 Docker Basics

**Commandes :**

```bash
# Vérifier les Dockerfiles
ls /home/dbhujoo/Desktop/inception/srcs/requirements/*/Dockerfile
ls /home/dbhujoo/Desktop/inception/srcs/requirements/bonus/*/Dockerfile

# Vérifier que les images ont le même nom que les services
docker images --format "table {{.Repository}}\t{{.Tag}}"
# ✅ Images : mariadb, nginx, wordpress, redis, ftp, adminer, cadvisor, static-site

# Vérifier les conteneurs créés
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml ps
```

### 3.6 Docker Network

**Commandes :**

```bash
# Lister les réseaux
docker network ls
# ✅ Doit montrer le réseau 'inception' ou 'srcs_inception'

# Inspecter le réseau
docker network inspect srcs_inception
# ✅ Doit montrer tous les conteneurs connectés
```

**Explication Docker Network :**
> Un réseau Docker permet aux conteneurs de communiquer entre eux de manière isolée. Le driver `bridge` crée un réseau privé où les conteneurs peuvent se joindre par leur nom (DNS interne). Cela évite d'exposer les ports internes à l'hôte.

### 3.7 NGINX avec SSL/TLS

**Commandes :**

```bash
# Vérifier le conteneur
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml ps nginx

# Vérifier le Dockerfile
cat /home/dbhujoo/Desktop/inception/srcs/requirements/nginx/Dockerfile

# Tester port 80 (doit échouer)
curl -I http://localhost:80 2>&1
# ✅ Connection refused

# Tester port 443 (doit fonctionner)
curl -kI https://dbhujoo.42.fr:443
# ✅ HTTP/1.1 200 OK

# Vérifier TLS
echo | openssl s_client -connect dbhujoo.42.fr:443 2>/dev/null | openssl x509 -noout -dates
# ✅ Affiche les dates de validité du certificat
```

### 3.8 WordPress avec php-fpm et son volume

**Commandes :**

```bash
# Vérifier le conteneur
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml ps wordpress

# Vérifier qu'il n'y a PAS NGINX dans le Dockerfile
grep -i nginx /home/dbhujoo/Desktop/inception/srcs/requirements/wordpress/Dockerfile
# ✅ Aucun résultat

# Vérifier le volume
docker volume ls
docker volume inspect srcs_wordpress
# ✅ Doit contenir : "device": "/home/dbhujoo/data/wordpress"

# Vérifier les données persistent
ls -la /home/dbhujoo/data/wordpress/
```

**Tests WordPress :**
1. ✅ Ajouter un commentaire avec un utilisateur
2. ✅ Se connecter en admin : https://dbhujoo.42.fr/wp-admin
3. ✅ Vérifier que le nom admin ne contient PAS "admin/Admin"
4. ✅ Modifier une page et vérifier la mise à jour

### 3.9 MariaDB et son volume

**Commandes :**

```bash
# Vérifier le conteneur
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml ps mariadb

# Vérifier qu'il n'y a PAS NGINX dans le Dockerfile
grep -i nginx /home/dbhujoo/Desktop/inception/srcs/requirements/mariadb/Dockerfile
# ✅ Aucun résultat

# Vérifier le volume
docker volume inspect srcs_mariadb
# ✅ Doit contenir : "device": "/home/dbhujoo/data/mariadb"

# Se connecter à la base de données
docker exec -it mariadb mariadb -u root -p
# Entrer le mot de passe root (depuis secrets/db_root_password.txt)

# Vérifier la base de données
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
# ✅ La base n'est pas vide
```

### 3.10 Persistance

**Procédure :**

```bash
# 1. Rebooter la VM
sudo reboot

# 2. Après redémarrage, relancer docker compose
cd /home/dbhujoo/Desktop/inception && make

# 3. Vérifier que tout fonctionne
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml ps

# 4. Vérifier que les données persistent
# - Le site WordPress doit afficher les mêmes contenus
# - Les modifications faites précédemment doivent être visibles
curl -kI https://dbhujoo.42.fr
```

### 3.11 Modification de configuration

**Exemple : Changer le port HTTPS de 443 à 8443**

```bash
# 1. Modifier docker_compose.yml
# Changer : ports: - "443:443" 
# En :      ports: - "8443:443"

# 2. Rebuild et restart
cd /home/dbhujoo/Desktop/inception
make re

# 3. Vérifier
docker ps
curl -kI https://dbhujoo.42.fr:8443
# ✅ Le service doit être accessible sur le nouveau port
```

---

## 4. Bonus

### 4.1 Redis Cache

**Commandes de vérification :**

```bash
# Vérifier le conteneur
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml ps redis

# Vérifier le Dockerfile
cat /home/dbhujoo/Desktop/inception/srcs/requirements/bonus/redis/Dockerfile

# Tester la connexion Redis
docker exec -it redis redis-cli ping
# ✅ Doit retourner PONG

# Vérifier l'intégration WordPress
docker exec -it wordpress wp redis status --allow-root --path=/var/www/wordpress
# ✅ Doit montrer "Status: Connected"

# Voir les clés en cache
docker exec -it redis redis-cli keys '*'
```

**Explication Redis :**
> Redis est un cache en mémoire qui stocke les résultats des requêtes MySQL fréquentes. Cela réduit la charge sur la base de données et accélère le temps de réponse du site (~1000x plus rapide pour les données en cache).

### 4.2 Serveur FTP

**Commandes de vérification :**

```bash
# Vérifier le conteneur
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml ps ftp

# Vérifier les ports
docker ps --format "table {{.Names}}\t{{.Ports}}" | grep ftp
# ✅ Ports 21 et 21100-21110 exposés

# Tester la connexion FTP (installer lftp si nécessaire)
lftp -u ftpuser ftp://localhost
# Entrer le mot de passe FTP

# Lister les fichiers WordPress
ls
# ✅ Doit montrer les fichiers WordPress
```

### 4.3 Site Statique

**Commandes de vérification :**

```bash
# Vérifier le conteneur
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml ps static-site

# Accéder au site
curl -I http://localhost:8080
# ✅ HTTP/1.1 200 OK

# Ouvrir dans un navigateur
# http://localhost:8080
# ✅ Doit afficher le site statique (portfolio/CV)
```

**Note :** Le site est en HTML/CSS (pas de PHP) ✅

### 4.4 Adminer

**Commandes de vérification :**

```bash
# Vérifier le conteneur
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml ps adminer

# Accéder via NGINX (proxy)
# https://dbhujoo.42.fr/adminer/
# Ou directement sur le port interne (si exposé)

# Se connecter avec :
# - Système : MySQL
# - Serveur : mariadb
# - Utilisateur : (depuis .env)
# - Mot de passe : (depuis secrets/)
# - Base de données : wordpress
```

### 4.5 cAdvisor (Service au choix)

**Commandes de vérification :**

```bash
# Vérifier le conteneur
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml ps cadvisor

# Accéder à l'interface web
# http://localhost:8081
# ✅ Affiche les métriques de tous les conteneurs

# Vérifier les métriques
curl http://localhost:8081/metrics | head -50
```

**Justification cAdvisor :**
> cAdvisor (Container Advisor) fournit des métriques en temps réel sur l'utilisation des ressources (CPU, mémoire, réseau, disque) de chaque conteneur. C'est utile pour :
> - Monitorer la santé de l'infrastructure
> - Détecter les problèmes de performance
> - Planifier les ressources nécessaires

---

## 5. Commandes Utiles

### Commandes de diagnostic

```bash
# Voir tous les conteneurs
docker ps -a

# Voir les logs d'un service
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml logs nginx
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml logs wordpress
docker compose -f /home/dbhujoo/Desktop/inception/srcs/docker_compose.yml logs mariadb

# Logs en temps réel
make logs

# Entrer dans un conteneur
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash

# Voir les réseaux
docker network ls
docker network inspect srcs_inception

# Voir les volumes
docker volume ls
docker volume inspect srcs_wordpress
docker volume inspect srcs_mariadb

# Voir les images
docker images

# Voir l'utilisation des ressources
docker stats
```

### Commandes Makefile disponibles

```bash
make          # Lance le projet (up)
make up       # Build et lance les conteneurs
make down     # Arrête et supprime les conteneurs
make stop     # Arrête les conteneurs
make start    # Démarre les conteneurs arrêtés
make re       # Relance (down + up)
make clean    # Supprime conteneurs + prune système
make fclean   # Clean + supprime les données des volumes
make status   # Affiche docker ps
make logs     # Affiche les logs en temps réel
```

---

## 📊 Récapitulatif des Points de Vérification

### ✅ Préliminaires & Structure

| Section         | Élément                 | Status |
|:----------------|:------------------------|:------:|
| Préliminaires   | Secrets sécurisés       |   ✅   |
| Structure       | `srcs/` à la racine     |   ✅   |
| Structure       | `Makefile` à la racine  |   ✅   |

### ✅ docker-compose.yml

| Élément   | Critère                  | Status |
|:----------|:-------------------------|:------:|
| Interdit  | Pas de `network: host`   |   ✅   |
| Interdit  | Pas de `links:`          |   ✅   |
| Requis    | `networks:` présent      |   ✅   |

### ✅ Dockerfiles & Scripts

| Élément      | Critère                   | Status |
|:-------------|:--------------------------|:------:|
| Dockerfiles  | Pas de `--link`           |   ✅   |
| Dockerfiles  | Pas de `tail -f`          |   ✅   |
| Dockerfiles  | Base `debian:bookworm`    |   ✅   |
| Scripts      | Pas de boucles infinies   |   ✅   |

### ✅ Documentation

| Fichier      | Critère                      | Status |
|:-------------|:-----------------------------|:------:|
| README.md    | Format correct (1ère ligne)  |   ✅   |
| USERDOC.md   | Instructions utilisateur     |   ✅   |
| DEVDEC.md    | Instructions développeur     |   ✅   |

### ✅ Services Obligatoires

| Service      | Critère               | Status |
|:-------------|:----------------------|:------:|
| NGINX        | Port 443 uniquement   |   ✅   |
| NGINX        | TLS v1.2/v1.3         |   ✅   |
| WordPress    | PHP-FPM sans NGINX    |   ✅   |
| WordPress    | Volume persistant     |   ✅   |
| MariaDB      | Volume persistant     |   ✅   |
| Persistance  | Données après reboot  |   ✅   |

### ⭐ Bonus

| Service      | Description                  | Status |
|:-------------|:-----------------------------|:------:|
| Redis        | Cache WordPress              |   ✅   |
| FTP          | Accès fichiers WordPress     |   ✅   |
| Static Site  | Site HTML/CSS (portfolio)    |   ✅   |
| Adminer      | Interface gestion BDD        |   ✅   |
| cAdvisor     | Monitoring conteneurs        |   ✅   |

---

*Document généré pour faciliter l'évaluation du projet Inception de dbhujoo*
