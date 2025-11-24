# ---------------------------------------------
# Configurações
# ---------------------------------------------
PHP_CONTAINER=setup-laravel_php
MYSQL_CONTAINER=setup-laravel_mysql
REDIS_CONTAINER=setup-laravel_redis
POSTGRES_CONTAINER=eventstore

# ---------------------------------------------
# Docker Básico
# ---------------------------------------------

up:
	docker compose up -d

up-build:
	docker compose up -d --build

down:
	docker compose down

restart:
	docker compose down
	docker compose up -d

logs:
	docker logs -f $(container)

# ---------------------------------------------
# Laravel - Artisan / Composer
# ---------------------------------------------

migrate:
	docker exec -it $(PHP_CONTAINER) php artisan migrate

seed:
	docker exec -it $(PHP_CONTAINER) php artisan db:seed

fresh:
	docker exec -it $(PHP_CONTAINER) php artisan migrate:fresh --seed

artisan:
	docker exec -it $(PHP_CONTAINER) php artisan $(cmd)

composer:
	docker exec -it $(PHP_CONTAINER) composer $(cmd)

# ---------------------------------------------
# Laravel - Limpeza de Cache
# ---------------------------------------------

clear:
	docker exec -it $(PHP_CONTAINER) php artisan optimize:clear

cache:
	docker exec -it $(PHP_CONTAINER) php artisan config:clear
	docker exec -it $(PHP_CONTAINER) php artisan cache:clear
	docker exec -it $(PHP_CONTAINER) php artisan route:clear
	docker exec -it $(PHP_CONTAINER) php artisan view:clear

# ---------------------------------------------
# Acesso rápido a containers
# ---------------------------------------------

shell:
	docker exec -it $(PHP_CONTAINER) bash

# ------------------
# MYSQL
# ------------------

mysql:
	docker exec -it $(MYSQL_CONTAINER) mysql -u developer -p123456

mysql-shell:
	docker exec -it $(MYSQL_CONTAINER) bash

mysql-log:
	docker logs -f $(MYSQL_CONTAINER)

mysql-reset:
	docker exec -it $(MYSQL_CONTAINER) bash -c "mysql -u developer -p123456 -e 'DROP DATABASE IF EXISTS db_laravel;'"
	docker exec -it $(MYSQL_CONTAINER) bash -c "mysql -u developer -p123456 -e 'CREATE DATABASE db_laravel;'"

# ------------------
# REDIS
# ------------------

redis:
	docker exec -it $(REDIS_CONTAINER) redis-cli

# ------------------
# POSTGRES (EVENT STORE)
# ------------------

postgres:
	docker exec -it $(POSTGRES_CONTAINER) psql -U event_user -d eventstore

postgres-shell:
	docker exec -it $(POSTGRES_CONTAINER) bash

postgres-log:
	docker logs -f $(POSTGRES_CONTAINER)

postgres-reset:
	docker exec -it $(POSTGRES_CONTAINER) bash -c "psql -U event_user -d eventstore -c 'DROP SCHEMA public CASCADE;'"
	docker exec -it $(POSTGRES_CONTAINER) bash -c "psql -U event_user -d eventstore -c 'CREATE SCHEMA public;'"

# ---------------------------------------------
# Logs úteis
# ---------------------------------------------

laravel-log:
	docker exec -it $(PHP_CONTAINER) tail -f storage/logs/laravel.log


# ---------------------------------------------
# Setup Inicial do Projeto Laravel
# ---------------------------------------------

setup:
	docker exec -it $(PHP_CONTAINER) bash -c "cp .env.example .env"
	docker exec -it $(PHP_CONTAINER) composer install
	docker exec -it $(PHP_CONTAINER) php artisan key:generate
	docker exec -it $(PHP_CONTAINER) php artisan migrate
