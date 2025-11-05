# Solution à l'Examen

## Description des Livrables

La présente archive `.zip` contient :

-   Le présent README_solution.md.
-   **Tous les `Dockerfiles`** nécessaires pour construire les images des services.
-   Le fichier **`docker-compose.yml`** orchestrant tous les services (Nginx, api-v1, api-v2, monitoring).
-   Le fichier **`nginx.conf`** complet avec toutes les directives requises.
-   Les fichiers de configuration et de sécurité (`.htpasswd`, certificats SSL, `prometheus.yml`).
-   Le code source des deux versions de l'API.
-   Un **`Makefile`** avec des commandes claires pour `start-project`, `stop-project`, `test`, `help` (description de la commande).
-   Un script de test (`tests/run_tests.sh`) qui valide automatiquement les fonctionnalités clés.
-   les certificats ont été créés avec les commandes suivantes :

```bash
# creation d'un certificat autosigné
mkdir -p deployments/nginx/certs/
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout deployments/nginx/certs/nginx.key -out deployments/nginx/certs/nginx.crt -subj "/CN=localhost"
# generation d'un fichier user/mot de passe htpasswd (initialisation avec un premier user admin/admin)
htpasswd -cb deployments/nginx/.htpasswd admin admin
```

-   Le tableau de bord grafana NGINX déjà prêt **`NGINX_exporter.json`** et sa configuration associée pour le referencer **`dashboards.yaml`** et connecter son datasource prometheus **`datasource.yaml`**

## Architecture de la solution

```mermaid
graph TD
    subgraph "Utilisateur"
        U[Client] -->|Requête HTTPS| N
    end

    subgraph "Infrastructure Conteneurisée (Docker)"
        N[Nginx Gateway] -->|Load Balancing| V1
        N -->|"A/B Test (Header)"| V2

        subgraph "API v1 (Scalée)"
            V1[Upstream: api-v1]
            V1_1[Replica 1]
            V1_2[Replica 2]
            V1_3[Replica 3]
            V1 --- V1_1
            V1 --- V1_2
            V1 --- V1_3
        end

        subgraph "API v2 (Debug)"
            V2[Upstream: api-v2]
        end

        subgraph "Stack de Monitoring"
            N -->|/nginx_status| NE[Nginx Exporter]
            NE -->|Métriques| P[Prometheus]
            P -->|Source de données| G[Grafana]
            U_Grafana[Admin] -->|Consulte Dashboards| G
        end
    end

    style N fill:#269539,stroke:#333,stroke-width:2px,color:#fff
    style G fill:#F46800,stroke:#333,stroke-width:2px,color:#fff
    style P fill:#E6522C,stroke:#333,stroke-width:2px,color:#fff
```

## Utilisation

### Prérequis

- Docker et Docker Compose (v1.X pour les commandes docker-compose et non docker compose) installés sur la machine hôte
- `make` disponible dans le PATH
- Ports suivants libres sur la machine :
  - `443` pour l'API via Nginx (HTTPS)
  - `8080` éventuel si redirection alternative
  - `9090` pour Prometheus
  - `3000` pour Grafana

### Commandes générales

```bash
# démarrage
make start-project

# lancement de la batterie de test d'intégration
make test

# arrêt complet
make stop-project

