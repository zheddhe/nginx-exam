SHELL := /bin/bash
.ONESHELL:
# flags de gestion du comportement sur erreur (sortie immediate et sur premiere erreur en pipe)
.SHELLFLAGS := -eu -o pipefail -c
# cible make par defaut : help
.DEFAULT_GOAL := help

PROJECT_NAME := mlops

start-project: ## Démarrage de la plateforme
	docker-compose -p $(PROJECT_NAME) up -d --build
	@echo "Grafana UI: http://localhost:3000"

stop-project: ## Arrêt de la plateforme
	docker-compose -p $(PROJECT_NAME) down

test-api: ## Test unitaire de l'API A (standard)
	curl -X POST "https://localhost/predict" \
     -H "Content-Type: application/json" \
     -d '{"sentence": "Oh yeah, that was soooo cool!"}' \
	 --user admin:admin \
     --cacert ./deployments/nginx/certs/nginx.crt

test-api-debug: ## Test unitaire de l'API B (debug)
	curl -X POST "https://localhost/predict" \
     -H "Content-Type: application/json" \
	 -H "X-Experiment-Group: debug" \
     -d '{"sentence": "Oh yeah, that was soooo cool!"}' \
	 --user admin:admin \
     --cacert ./deployments/nginx/certs/nginx.crt

test: ## Lance la batterie de tests d'intégration (make test appelé par l'examinateur)
	./tests/run_tests.sh

help: ## Affiche cette aide
	@awk 'BEGIN{FS=":.*##"; printf "\nTargets disponibles:\n\n"} /^[a-zA-Z0-9_.-]+:.*##/{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2} /^.DEFAULT_GOAL/{print ""} ' $(MAKEFILE_LIST)
