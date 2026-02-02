# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dbhujoo <dbhujoo@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/01/28 13:30:24 by dbhujoo           #+#    #+#              #
#    Updated: 2026/02/02 16:30:25 by dbhujoo          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

all: up

up:
	docker compose -f ./srcs/docker_compose.yml up -d --build

down:
	docker compose -f ./srcs/docker_compose.yml down

stop:
	docker compose -f ./srcs/docker_compose.yml stop

start:
	docker compose -f ./srcs/docker_compose.yml start

re: down up

clean: down
	docker system prune -af

fclean: clean
	rm -rf /home/dbhujoo/data/mariadb/*
	rm -rf /home/dbhujoo/data/wordpress/*

status:
	docker ps

logs:
	docker compose -f ./srcs/docker_compose.yml logs -f

.PHONY: all up down stop start re clean fclean status logs