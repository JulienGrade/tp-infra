<h1>Tp Docker et MongoDB</h1><br/>
<h2>Pré-conditions</h2>
<p>Avant de se lancer sur le tp, on doit vérifier que docker fonctionne sur notre machine</p>
<ul>
    <li>On vérifie la présence de Docker et sa version :<br/>
        <code>
            docker --version
        </code><br/>
    </li>
    <li>
        On s’assure que Docker est bien démarré :<br/>
        <code>docker ps</code><br/>
        Si tu as un “command not found” ou “Cannot connect to the Docker daemon” → 
        il faut d’abord faire fonctionner Docker, sinon on ne continue pas.
    </li>
</ul>

<h2>Étape 1 – Créer le dossier du TP</h2>
<code>
mkdir -p 01-docker-mongo
cd 01-docker-mongo
</code>
<h2>Étape 2 – Créer le fichier docker-compose.yml</h3>
<p>Crée un fichier appelé docker-compose.yml dans ce dossier et mets-y le contenu
du pdf</p>
<p>Si ça rate :<br/>
- vérifie le nom du fichier (pas d’extension .txt)
- vérifie l’indentation YAML (2 espaces devant mongo : et les clés en dessous)
</p>
<h2>Étape 3 – Démarrer MongoDB</h2>
<p>Toujours dans 01-docker-mongo :</p>
<code>docker compose up -d
</code>
<p>
La commande ne doit pas afficher d’erreur.
Vérifie que le conteneur tourne :<br/>
<code>docker ps</code>
</p>
<p>
Si ça rate :<br/>
- si le message dit “no such file or directory” → tu n’es pas dans le bon dossier<br/>
- si le message dit “docker-compose: command not found” → essaie avec docker compose (sans tiret)<br/>
- si l’image ne se télécharge pas → vérifier la connexion internet<br/>

Tant que docker ps ne montre pas ton conteneur mongo, on ne passe pas à l’étape 4.
</p>
<h2>Étape 4 – Entrer dans MongoDB avec mongosh</h2>
<p>On exécute un shell Mongo dans le conteneur :</p>
<code>docker exec -it mongo mongosh -u root -p example
</code>
<p>Tu dois passer dans un prompt Mongo du genre :</p>
<code>test>
</code><br>
ou<br>
<code>>
</code>
<p>Si ça rate : <br>

“No such container” → ton conteneur ne s’appelle pas mongo → fais docker ps pour voir le nom exact
“mongosh: not found” → tu n’as pas l’image officielle récente → on reprendra l’image mongo:7
</p>
<h2>Étape 5 – Créer une vraie base</h2>
<p>Mongo ne “crée” pas une DB tant qu’on n’a rien dedans.</p>
<p>À saisir dans le shell mongo :</p>
<code>
use myapp
</code><br/>
<code>
db.createCollection("users")
</code><br/>
<code>
db.users.insertOne({ name: "Alice" })
</code><br/>
<code>
show dbs
</code><br/>
<code>
show collections
</code>
<p>
Validation attendue :

show collections doit afficher users<br/>
show dbs doit afficher myapp (parfois après une autre commande, c’est normal)<br/>
pas d’erreur sur l’insertion
</p>
<p>
Si ça rate :

Si show dbs n’affiche pas myapp, refais une insertion<br>
Si tu as une erreur de droits, vérifie bien que tu es connecté avec -u root -p example
</p>
<p>Quand c’est bon, tu peux faire :</p>
<code>exit</code><br/>
<h2>Étape 6 – Arrêter ou laisser tourner</h2>
<p>Option A – laisser tourner
Ne fais rien, le conteneur continue à tourner.</p>
<p>Option B – arrêter</p>
<code>docker compose down</code>
<p>Vérifier l’arrêt du conteneur : ne doit plus afficher mongo</p>
<code>docker ps</code><br/>