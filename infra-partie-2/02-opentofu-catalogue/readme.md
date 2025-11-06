<h1>ATELIER 2 – Stack locale “catalogue API” (OpenTofu + Docker)</h1>
<h2>Créer la structure</h2>
<p>Vous devez créer un dossier pour ce nouveau tp, il doit contenir un dossier
api et un fichier main.tf à la racine, car on veut séparer infra (les .tf) et code (l’API).</p>
<h2>Étape 2 – Mettre le provider Docker dans main.tf</h2>
<p>On met en place la même base que sur le tp précédent</p>
<code>
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
host = "unix:///var/run/docker.sock"
}

</code>
<h2>Étape 3 – Déclarer le réseau Docker de la stack</h2>
<p>Dans ce TP, on veut que Postgres, Redis et l’API soient sur le même réseau Docker dédié, pas sur le network bridge par défaut.</p>
<p>Donc, on ajoute tout de suite une ressource réseau :</p>
<code>
resource "docker_network" "catalogue_net" {
  name = "catalogue-net"
}
</code>
<p>Validation :<br/>
ton main.tf contient maintenant 3 blocs :<br/>

terraform { ... }<br/>

provider "docker" { ... }<br/>

resource "docker_network" "catalogue_net" { ... }
</p>
<h2>Étape 4 – Initialiser</h2>
<p>Toujours dans ce dossier :</p>
<code>tofu init
</code>
<p>Comme pour le TP 1, tu dois voir :<br/>

“Initializing provider plugins…”<br/>

“Installed kreuzwerker/docker …”<br/>

“OpenTofu has been successfully initialized!”
</p>
<h2>Étape 5 – Ajouter PostgreSQL géré par OpenTofu</h2>
<p>L’idée :</p>
<ol>
<li>Créer un volume Docker pour que les données survivent</li>
<li>Lancer un conteneur Postgres sur notre réseau catalogue-net</li>
<li>Exposer le port 5432 en local pour que tu puisses te connecter depuis ton IDE</li>
</ol>
<p>Ajoute ceci dans ton main.tf (sous le réseau) :</p>
<code>
# Volume pour les données Postgres
resource "docker_volume" "pg_data" {
  name = "catalogue-pg-data"
}

# Conteneur Postgres
resource "docker_container" "postgres" {
    name  = "catalogue-postgres"
    image = "postgres:15-alpine"

    env = [
    "POSTGRES_USER=catalogue",
    "POSTGRES_PASSWORD=catalogue",
    "POSTGRES_DB=catalogue",
    ]

    networks_advanced {
        name = docker_network.catalogue_net.name
    }

    mounts {
        target = "/var/lib/postgresql/data"
        source = docker_volume.pg_data.name
        type   = "volume"
    }

    ports {
        internal = 5432
        external = 5432
    }
}

</code>
<p>Ce que fait chaque bloc :</p>
<ul>
<li>docker_volume.pg_data → évite de perdre la DB à chaque tofu apply</li>
<li>env = [...] → on met un utilisateur/mot de passe simples pour le TP</li>
<li>networks_advanced { ... } → on branche le conteneur sur notre réseau catalogue-net</li>
<li>ports { … } → on peut faire psql ou se connecter depuis un client DB sur localhost:5432</li>
</ul>
<h2>Étape 6 – Voir le plan</h2>
<p>Dans le dossier :</p>
<code>tofu init
</code>
<code>tofu plan
</code>
<p>Tu dois voir maintenant 3 ressources à créer :</p>
<p>
- le réseau<br/>
- le volume<br/>
- le conteneur postgres<br/>
</p>
<p>Sortie attendue :</p>
<code>
Plan: 3 to add, 0 to change, 0 to destroy.
</code>
<h2>Appliquer</h2>
<code>tofu apply</code>
<p>Réponds yes comme précédemment</p>
<h2>Étape 8 – Valider que le conteneur est bien là</h2>
<code>docker ps</code>
<p>Tu dois voir un conteneur :<br/>

IMAGE : postgres:15-alpine<br/>

PORTS : 0.0.0.0:5432->5432/tcp<br/>

NAMES : catalogue-postgres</p>

<h2>Étape 9 – Ajouter Redis à la stack</h2>
<p>Dans ton main.tf, juste après le bloc docker_container "postgres", ajoute :</p>
<code>
resource "docker_container" "redis" {
  name  = "catalogue-redis"
  image = "redis:7-alpine"

    networks_advanced {
        name = docker_network.catalogue_net.name
    }

    ports {
        internal = 6379
        external = 6379
    }
}

</code>
<p>Ce que ça fait :</p>
<ul>
<li>Conteneur Redis léger (redis:7-alpine)</li>
<li>Branché sur le même réseau Docker (catalogue-net)</li>
<li>Exposé sur le port 6379 → tu pourras tester avec un client Redis local si tu veux</li>
</ul>
<h2>Étape 10 – Replanifier</h2>
<p>Comme on a jouté une ressource : </p>
<code>
tofu init
tofu apply
</code>
<p>Oui, on refait un petit tofu init dès qu’on touche au provider ou qu’OpenTofu râle sur le lock file</p>
<p>Validation attendue :</p>
<code>
Plan: 4 to add, 0 to change, 0 to destroy.
</code>
<h2>Appliquer</h2>
<code>tofu apply</code>
<p>puis yes</p>
<h2>Étape 12 – Vérifier côté Docker</h2>
<code>docker ps</code>
<p>
Tu dois voir maintenant 2 conteneurs de ta stack :<br/>

catalogue-postgres (5432→5432)<br/>

catalogue-redis (6379→6379)<br/>

Tous les deux sur le réseau catalogue-net.
</p>
<p>À ce stade, tu as ton socle de services (DB + cache)</p>
<p>La prochaine étape du TP sera de brancher un conteneur “API catalogue” (souvent un petit Node/Express) sur ce réseau, avec les bonnes variables d’environnement pour parler à Postgres et Redis.</p>

<p>On va le faire “propre IaC” façon OpenTofu :<br/>

tu mets ton code API dans api/<br/>

on fait un petit Dockerfile dedans<br/>

OpenTofu construit l’image depuis ce dossier<br/>

OpenTofu lance le conteneur sur le réseau catalogue-net avec les bonnes variables d’environnement</p>
<h2>Étape 13 – Préparer le code de l’API</h2>
<p>Dans le dossier api, on ajouter un fichier Dockerfile avec ce contenu :</p>
<code>
FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY . .
EXPOSE 3000
CMD ["npm", "start"]

</code>
<p>Et ajouter également un package.json minimale : </p>
<code>
{
  "name": "catalogue-api",
  "version": "1.0.0",
  "main": "index.js",
  "type": "module",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.19.2",
    "pg": "^8.12.0",
    "ioredis": "^5.4.1"
  }
}

</code>
<p>Ensuite, on ajoute un fichier index.js avec un code d'api très simple :</p>
<code>
import express from "express";

const app = express();
const port = process.env.PORT || 3000;

app.get("/", (req, res) => {
    res.json({
        status: "ok",
        message: "Catalogue API",
        postgres: {
        host: process.env.PGHOST,
        db: process.env.PGDATABASE,
        user: process.env.PGUSER
        },
        redis: {
        host: process.env.REDIS_HOST
        }
    });
});

app.listen(port, () => {
    console.log(`API catalogue démarrée sur le port ${port}`);
});

</code>

<h2>Étape 14 – Dire à OpenTofu de construire l’image API</h2>
<p>On retourne dans main.tf (à la racine du TP) et on ajoute après Redis :</p>
<code>
# Image de l'API catalogue (build local depuis ./api)
resource "docker_image" "catalogue_api" {
  name = "catalogue-api:latest"

    build {
    context = "${path.module}/api"
    }
}

</code>
<p>Ça dit à OpenTofu : “va dans le dossier api/ et construis-moi une image Docker qui s’appelle catalogue-api:latest”.</p>
<h2>Étape 15 – Lancer le conteneur API sur le même réseau</h2>
<p>Toujours dans main.tf, juste après l’image :</p>
<code>
resource "docker_container" "catalogue_api" {
    name  = "catalogue-api"
    image = docker_image.catalogue_api.image_id

    networks_advanced {
        name = docker_network.catalogue_net.name
    }

    # on publie pour tester depuis le navigateur
    ports {
        internal = 3000
        external = 3000
    }

    env = [
        "PORT=3000",
        "PGHOST=catalogue-postgres",
        "PGUSER=catalogue",
        "PGPASSWORD=catalogue",
        "PGDATABASE=catalogue",
        "REDIS_HOST=catalogue-redis",
        "REDIS_PORT=6379"
    ]

    depends_on = [
        docker_container.postgres,
        docker_container.redis
    ]
}

</code>
<p>Points importants :</p>
<ul>
<li>depends_on → on attend que Postgres et Redis soient là</li>
<li>On utilise les noms des conteneurs Postgres/Redis comme hostnames (catalogue-postgres, catalogue-redis), parce qu’ils sont sur le même réseau Docker</li>
<li>On publie le port 3000 pour tester avec http://localhost:3000</li>
</ul>
<h2>Étape 16 – Re-init (on a ajouté un build)</h2>
<p>Comme on a ajouté un bloc build {}, on refait :</p>
<code>
tofu init
tofu plan
</code>
<p>Ce que tu dois voir dans le plan maintenant :<br/>

1 réseau<br/>

1 volume<br/>

2 containers (postgres, redis)<br/>

1 image buildée<br/>

1 container API<br/>
En bref, 5 ressources à créer.</p>
<p>Sortie attendue :</p>
<code>Plan: 5 to add, 0 to change, 0 to destroy.
</code>
<h2>Étape 17 – Appliquer</h2>
<code>tofu apply</code>
<p>Là ça va :<br/>

builder l’image (un peu plus long)<br/>

lancer Postgres<br/>

lancer Redis<br/>

lancer l’API</p>
<h2>Étape 18 – Vérifier</h2>
<code>docker ps</code>
<p>Tu dois voir :<br/>

catalogue-postgres<br/>

catalogue-redis<br/>

catalogue-api (3000->3000)</p>
<p>Dans ton navigateur :</p>
<a href="http://localhost:3000">http://localhost:3000</a>
<p>Tu dois avoir un JSON du type :</p>
<code>
{
  "status": "ok",
  "message": "Catalogue API",
  "postgres": {
    "host": "catalogue-postgres",
    "db": "catalogue",
    "user": "catalogue"
  },
  "redis": {
    "host": "catalogue-redis"
  }
}

</code>
<h2>Étape 19 – Nettoyage</h2>
<p>Dans le dossier tp :</p>
<code>tofu destroy</code>
<p>OpenTofu va te demander confirmation :</p>
<p>tapes yes</p>
<p>Validation, à la fin tu dois voir :</p>
<code>
Destroy complete! Resources: 6 destroyed.
</code>
<p>Puis avec docker ps, tu ne dois plus voir de conteneur catalogue-*</p>
<h2>Dépannage</h2>

- Erreur `port is already allocated` sur 5432 ou 6379 :
    - soit arrêter le service déjà présent
    - soit changer `external = 5433` (ou 6380) dans main.tf puis refaire `tofu apply`

- Erreur `Cannot connect to the Docker daemon` :
    - lancer Docker Desktop
    - re-tester avec `docker ps`
    - relancer `tofu plan`

- L’image API ne se build pas :
    - vérifier que le dossier `api/` est au même niveau que `main.tf`
    - vérifier le nom du fichier `Dockerfile`
    - relancer `tofu apply`
