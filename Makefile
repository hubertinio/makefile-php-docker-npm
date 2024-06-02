# Executables (local)
DOCKER_COMP = docker-compose

PHP_SERVICE = app
DB_SERVICE = database

# Make Makefile available for users without Docker setup
ifeq ($(APP_DOCKER), 0)
	PHP_CONT =
	DB_CONT =
else
	PHP_CONT = $(DOCKER_COMP) exec $(PHP_SERVICE)
	DB_CONT = $(DOCKER_COMP) exec $(DB_SERVICE)
endif

# Executables
PHP = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) bin/composer
SYMFONY = $(PHP_CONT) bin/console
NPM = $(PHP_CONT) npm
NPX = $(PHP_CONT) npx
YRN = $(PHP_CONT) yarn

# Executables: vendors
PHPUNIT = $(PHP) bin/phpunit
PHPSPEC = $(PHP) bin/phpspec
ECS     = $(PHP) bin/ecs

# Misc
.DEFAULT_GOAL := help

##
## ——————————————————————————————————— TME Kalmar Makefile ———————————————————————————————————
##

help: ## Outputs help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

##
## —— Front 🐳 ————————————————————————————————————————————————————————————————
##

front: front-assets front-install front-lint front-build ## Front ready to go

front-assets: ## Install all assets
	$(SYMFONY) assets:install --no-debug

front-watch: ## Build dev and watch project
	$(PHP_CONT) rm -rf public/build/*
	$(NPM) run watch

front-install: ## Install node modules
	$(PHP_CONT) rm -rf node_modules
	$(NPM) install

front-build: ## Build prod project
	$(PHP_CONT) rm -rf public/build/*
	$(NPM) run build

front-lint: ## Run JS linter
	$(NPM) run lint:js

front-analyzer: ## Check stats
	$(PHP_CONT) rm -rf var/cache/stats.json
	$(PHP_CONT) rm -rf public/build/stats.html
	$(NPM) run --silent build --json > var/cache/stats.json
	$(NPX) webpack-bundle-analyzer --mode static --report public/build/stats.html --no-open var/cache/stats.json public/build

##
## —— Docker 🐳 ————————————————————————————————————————————————————————————————
##

build-containers-prod: ## Build project
	$(DOCKER_COMP) -f docker-compose.yml up -d build

start-containers-prod: ## Start all prod containers
	$(DOCKER_COMP) -f docker-compose.yml up -d --remove-orphans

start-containers: ## Start all containers
	$(DOCKER_COMP) -f docker-compose.yml up -d --remove-orphans

stop-containers: ## Stop all containers
	$(DOCKER_COMP) stop || exit 0

down-containers: ## Stop and remove containers
	$(DOCKER_COMP) down || exit 0

pull-containers: ## Pull containers from Docker hub
	$(DOCKER_COMP) pull --no-parallel --include-deps --ignore-pull-failures

build-containers: ## Build project
	$(DOCKER_COMP) -f docker-compose.yml build

logs: ## Show live logs
	$(DOCKER_COMP) logs --tail=30 --follow

sh: ## Connect to the PHP FPM container
	$(DOCKER_COMP) exec $(PHP_SERVICE) bash

ps: ## Display status of running containers
	$(DOCKER_COMP) ps

##
## —— Symfony 🎶️ ————————————————————————————————————————————————————————————————
##

security: ## Check security issues in project dependencies
	$(SYMFONY_CLI) security:check

##
## —— Composer 🧙‍♂️ ————————————————————————————————————————————————————————————————
##

composer-install: ## Install project dependencies
	$(COMPOSER) install

composer-reinstall: ## Reinstall composer dependencies
	$(COMPOSER) clearcache
	rm -rf vendor/*
	make composer-install

composer-dump: ## Dump composer
	$(COMPOSER) dump-autoload --optimize --classmap-authoritative --no-interaction --quiet

composer-validate: ## Validate composer json and lock
	$(COMPOSER) validate --ansi --strict

composer-dump-env: ## Compiles .env.local.php
	$(COMPOSER) symfony:dump-env prod

##
## —— Database 📜 ————————————————————————————————————————————————————————————————
##

schema-update: ## Force database schema
	$(SYMFONY) doctrine:schema:update --force --no-interaction

migrate: ## Make migrations
	$(SYMFONY) doctrine:migrations:migrate

migrations-status: ## Check migrations status
	$(SYMFONY) doctrine:migrations:status

migrations-generate: ## Create empty migration
	$(SYMFONY) doctrine:migrations:generate

migrations-diff: ## Create migration diff
	$(SYMFONY) doctrine:migrations:diff

fixture: ## Make fixtures and clear database
	$(SYMFONY) h:f:l --env=dev --no-interaction

##
## —— App ✔️ ————————————————————————————————————————————————————————————————
##

cache-clear: ## Whole caches out
	$(PHP_CONT) rm -rf var/cache/*
	$(PHP) -r "opcache_reset();"
	$(SYMFONY) cache:clear
	$(SYMFONY) cache:pool:prune

##
## —— Tests ✔️ ————————————————————————————————————————————————————————————————
##

test: phpunit phpspec e2e ## Run all kind of tests

phpunit: ## Run Unit tests
	$(SYMFONY) -e test doctrine:database:create --if-not-exists --no-interaction --quiet
	$(SYMFONY) -e test doctrine:schema:update --force --no-interaction --quiet
	$(PHPUNIT) -vvv tests/Unit --testdox

e2e: ## Run end-2-end tests
	$(PHPUNIT) -vvv tests/Integration --testdox

phpspec: ## Run PHP Spec tests
	$(PHPSPEC) run --ansi -f progress --no-interaction

##
## —— Quality Tools ✔️ ————————————————————————————————————————————————————————————————
##

linter: ## Run linter
	$(SYMFONY) lint:twig templates --no-debug
	$(SYMFONY) lint:xliff translations --no-debug
	$(SYMFONY) lint:container --no-debug

ecs: ## Run Easy Coding Standard
	$(ECS) check

ecs-fix: ## Fix all Easy Coding Standard issues
	$(ECS) check --fix

##
## ——————————————————————————————————— End ———————————————————————————————————
##
