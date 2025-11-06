<h1>Atelier Opentofu en local avec Docker</h1>
<h2>Étape 1 — Prérequis</h2>
<h3>Docker doit tourner</h3>
<code>docker ps
</code>
<p>Si tu vois une liste (même vide), c’est bon.<br/>
Si tu as “permission denied”, fais comme dans les tp précédents :
<code>sudo usermod -aG docker $USER
newgrp docker
docker ps
</code>
</p>
<h3>Opentofu doit être installé</h3>
<p>Vérification :</p>
<code>tofu version
</code>
<p>si la commande n’existe pas, tu installes (Linux) :</p>
<a href="https://opentofu.org/docs/intro/install/">Lien vers la page d'installation Opentofu</a>
<p>Validation attendue pour cette étape :</p>
<ul>
<li>docker ps fonctionne
</li>
<li>tofu version affiche un numéro
</li>
</ul>
<h2>Étape 2 — Créer le fichier principal main.tf</h2>
<p>On commence par créer un dossier pour ce tp puis on met un fichier minimal 
qui dit juste : “je vais parler à Docker”.</p>
<p>On y met le contenu suivant</p>
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
<p>Pourquoi comme ça ?</p>
<ul>
<li>kreuzwerker/docker = provider Docker le plus utilisé
</li>
<li>On fixe une version (~> 3.0) → bonne pratique
</li>
<li>On dit à OpenTofu d’utiliser le socket Docker local → pas de cloud</li>
</ul>
<p>Validation attendue : cat main.tf affiche bien ce contenu, le fichier est dans ton dossier de TP</p>
<h2>Étape 4 — Initialiser le projet</h2>
<p>Dans le terminal sur le dossier dans lequel tu as mis main.tf :</p>
<code>tofu init
</code>
<p>Ce que fait cette commande</p>
<ul>
<li>Elle lit ton main.tf</li>
<li>Elle voit que tu veux le provider kreuzwerker/docker</li>
<li>Elle télécharge ce provider dans un dossier caché (.tofu/)</li>
<li>Elle crée les fichiers nécessaires pour bosser</li>
</ul>
<p>Validation attendue, tu dois avoir dans la sortie :</p>
<code>Initializing the backend...<br/>
Initializing provider plugins...<br/>
- Finding kreuzwerker/docker versions matching "~> 3.0"...<br/>
- Installing kreuzwerker/docker v3.x.x...<br/>
- Installed kreuzwerker/docker v3.x.x (self-signed, key ID ...)
...
OpenTofu has been successfully initialized!
</code>
<p>Et si tu fais :</p>
<code>ls -a
</code>
<p>Tu dois voir apparaître un dossier .tofu/ (ou.terraform/ selon la version d’OpenTofu, les deux sont OK).</p>
<h2>Étape 5 — Déclarer ce qu’on veut créer</h2>
<p>Maintenant qu’OpenTofu est initialisé, on lui dit quoi gérer. Dans ce TP, on veut juste :</p>
<ol>
<li>Tirer l’image Docker nginx:latest</li>
<li>Lancer un conteneur depuis cette image</li>
<li>Publier le port 80 du conteneur sur le port 8080 de la machine</li>
</ol>
<p>Dans ton fichier main.tf, ajoute sous ce que tu as déjà (pas à la place) :</p>

<code>
resource "docker_image" "nginx" {
    name = "nginx:latest"
}

resource "docker_container" "nginx" {
    name  = "nginx"
    image = docker_image.nginx.image_id

    ports {
    internal = 80
    external = 8080
    }
}
</code>
<p>Ce que ça veut dire</p>
<ul>
<li>docker_image → “assure-toi que j’ai cette image en local”</li>
<li>docker_container → “lance un conteneur avec cette image”</li>
<li>bloc ports {} → “rends-le accessible sur http://localhost:8080”</li>
</ul>
<p>Validation : Dans ton terminal, juste pour vérifier :</p>
<code>cat main.tf
</code>
<p>Tu dois voir 3 blocs dans l’ordre :<br/>

terraform { ... }<br/>

provider "docker" { ... }<br/>

Les 2 ressources qu’on vient d’ajouter</p>
<h2>Étape 6 — Voir le plan</h2>
<p>Toujours dans le même dossier :</p>
<code>tofu plan
</code>
<p>Ce qui doit s’afficher, quelque chose comme ça :</p>
<code>OpenTofu will perform the following actions :

# docker_image.nginx will be created
# docker_container.nginx will be created

Plan: 2 to add, 0 to change, 0 to destroy.
</code>
<p>Ça veut dire : “je vais créer 2 ressources : l’image et le conteneur”.</p>
<p>Si tu as une erreur ici : <br/>

“Cannot connect to the Docker daemon…” : Docker n’est pas lancé : lance Docker Desktop puis refais tofu plan.

“port is already allocated” : tu as déjà quelque chose sur 8080 : change le port à 8081 par exemple.</p>
<h2>Étape 7 — Appliquer le plan (créer vraiment le conteneur)</h2>
<code>tofu apply
</code>
<p>OpenTofu va te remontrer le plan puis te demander :</p>
<code>Enter a value:
</code>
<p>Tu tapes :</p>
<code>yes
</code>
<p>Validation : la commande doit se terminer par un truc du genre :</p>
<code>Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
</code>
<p>Et si tu fais :</p>
<code>docker ps</code>
<p>Tu dois voir un conteneur nginx exposé sur 0.0.0.0:8080->80/tcp</p>
<h2>Étape 8 — Tester</h2>
<p>Dans ton navigateur :</p>
<a href="http://localhost:8080">http://localhost:8080</a>
<p>Tu dois voir la page nginx</p>
<h2>Étape 9 — Détruire ce qu’on vient de créer</h2>
<p>L’idée de l’infra as code, c’est aussi de pouvoir revenir en arrière aussi facilement qu’on a créé.</p>
<p>Dans le même dossier :</p>
<code>tofu destroy
</code>
<p>Tu vas revoir la liste des ressources (docker_image.nginx, docker_container.nginx) et OpenTofu va te demander confirmation :</p>
<code>Do you really want to destroy all resources?
  OpenTofu will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

Enter a value:
</code>
<p>Comme précédemment, vous pouvez saisir yes</p>
<p>Validation : la commande doit finir par :</p>
<code>Destroy complete! Resources: 2 destroyed.
</code>
<p>Ensuite tu fais :</p>
<code>docker ps</code>
<p>Le conteneur demo-nginx ne doit plus être là.</p>
<p>Ça prouve que c’est bien OpenTofu qui contrôle le cycle de vie du conteneur.</p>
<p>Afin de valider l’intérêt d'Opentofu dans la mise en place d'infrastructure, vous pouvez refaire 
les étapes tofu apply, tofu destroy, nginx repart.</p>
