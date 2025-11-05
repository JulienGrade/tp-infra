<h1>Atelier Minikube</h1>
<h2>Objectif</h2>
<p>Installer et exécuter Minikube sur ta VM Ubuntu (celle avec Docker),
puis déployer un service Nginx sur ton cluster Kubernetes local.</p>
<h2>Étape 1 : Vérifier l’environnement avant installation</h2>
<p>Dans ta VM :<br/>
<code>sudo docker ps
</code>
Si tu vois un conteneur ou une ligne vide (sans erreur), c’est bon.
</p>
<p>
Puis vérifie ta version d’Ubuntu :<br/>
<code>lsb_release -a
</code>
</p>
<h2>Étape 2 – Installer kubectl (le client Kubernetes)</h2>
<p>
Installer et tester kubectl, l’outil en ligne de commande permettant d’interagir avec Kubernetes.
Cette méthode est simplifiée et stable, idéale pour une VM Ubuntu locale.
</p>
<h3>Installation rapide avec Snap</h3>
<p>Ubuntu intègre nativement Snap, un gestionnaire de paquets officiel.
C’est la méthode la plus fiable et la plus simple pour installer kubectl sans erreurs de téléchargement.</p>
<p>Installer ou mettre à jour Snap</p>
<code>sudo apt update
sudo apt install -y snapd
sudo snap refresh
</code>
<p>Installer kubectl</p>
<code>sudo snap install kubectl --classic
</code>
<p>Vérifier l'installation</p>
<code>kubectl version --client
</code>
<p>Résultat attendu :</p>
<code>Client Version: version.Info{Major:"1", Minor:"31", GitVersion:"v1.31.x", ...}
</code>
<p>À ce stade, kubectl est opérationnel et prêt à piloter ton cluster Kubernetes local.</p>
<h2>Installation de Minikube</h2>
<p>Installer Minikube, un outil qui crée un cluster Kubernetes complet en local à l’aide de Docker.
Il va te permettre de tester Kubernetes sans avoir besoin d’un cloud.</p>
<p>Installation depuis Github</p>
<code>curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
</code>
<p>Cette commande télécharge automatiquement la version la plus récente pour Linux 64 bits.</p>
<p>Rendre le fichier executable</p>
<code>chmod +x minikube-linux-amd64
</code>
<p>Installer Minikube dans le dossier d’exécution</p>
<code>sudo mv minikube-linux-amd64 /usr/local/bin/minikube
</code>
<p>Vérifier l'installation</p>
<code>minikube version
</code>
<p>Vérifier le moteur Docker</p>
<code>sudo docker ps</code>
<p>Si tu obtiens une liste vide (et pas d’erreur), tout est bon.
Sinon, démarre le service</p>
<code>sudo systemctl start docker
</code>
<p>Autoriser ton utilisateur à utiliser Docker.</p>
<p>Minikube ne doit pas être lancé avec sudo.
Il faut donc que ton utilisateur appartienne au groupe docker :</p>
<code>sudo usermod -aG docker $USER
newgrp docker
</code>
<p>Lancer ton premier cluster kubernetes</p>
<code>minikube start --driver=docker
</code>
<p>Cette commande : télécharge les images Kubernetes nécessaires, crée une instance “minikube” locale (jouant le rôle de master et worker), configure automatiquement kubectl.</p>
<p>Validation du cluster :</p>
<code>Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default.
</code>
<p>Vérifier l’état du cluster :</p>
<code>minikube status
</code>
<p>Puis listes les nœuds :</p>
<code>kubectl get nodes
</code>
<p>Commandes utiles :</p>
<table>
<tr>
<td>Stopper le cluster</td>
<td>minikube stop</td>		
<td>Éteint le cluster proprement</td>
</tr>
<tr>
<td>Redémarrer</td>
<td>minikube start</td>		
<td>Relance le cluster</td>
</tr>
<tr>
<td>Supprimer le cluster</td>
<td>minikube delete</td>		
<td>Réinitialise tout</td>
</tr>
<tr>
<td>Vérifier les services</td>
<td>kubectl get all</td>		
<td>Liste toutes les ressources Kubernetes</td>
</tr>
</table>
<p>Dépannage rapide</p>
<table>
  <thead>
    <tr>
      <th>Message d’erreur</th>
      <th>Cause probable</th>
      <th>Solution</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>The docker driver should not be run with root privileges</td>
      <td>Lancement avec <code>sudo</code></td>
      <td>Relancer sans <code>sudo</code></td>
    </tr>
    <tr>
      <td>permission denied while trying to connect to Docker daemon</td>
      <td>Utilisateur non membre du groupe <code>docker</code></td>
      <td><code>sudo usermod -aG docker $USER && newgrp docker</code></td>
    </tr>
    <tr>
      <td>Minikube fails to start</td>
      <td>Docker inactif</td>
      <td><code>sudo systemctl start docker</code></td>
    </tr>
  </tbody>
</table>
<h2>Étape 11 – Déployer un petit service dans Minikube</h2>
<p>Créer le déploiement</p>
<code>kubectl create deployment nginx --image=nginx
</code>
<p>Ce que ça fait : Kubernetes va télécharger l’image nginx et créer un pod géré par un Deployment.</p>
<p>Validation :</p>
<code>kubectl get pods
</code>
<p>Tu dois voir un pod avec un nom qui commence par nginx-... et le statut qui passe à Running après quelques secondes.</p>
<h2>Étape 12 – Exposer nginx</h2>
<p>On veut pouvoir atteindre nginx depuis l’extérieur du cluster (au moins depuis la VM).</p>
<code>kubectl expose deployment nginx --type=NodePort --port=80
</code>
<p>Validation :</p>
<code>kubectl get services
</code>
<p>Tu dois voir une ligne nginx avec un PORT(S) du type 80:3xxxx/TCP → le 3xxxx est le NodePort.</p>
<h2>Étape 13 – Récupérer l’URL d’accès via Minikube</h2>
<p>Minikube a une commande pratique pour te donner l’URL directe :</p>
<code>minikube service nginx --url
</code>
<p>Ça doit t’afficher une URL du genre :</p>
<code>http://192.168.49.2:31052
</code>
<h2>Étape 14 – Tester</h2>
<p>Toujours dans la VM :</p>
<code>curl http://192.168.49.2:31052
</code>
<h2>Étape 15 - Nettoyage</h2>
<code>kubectl delete service nginx
kubectl delete deployment nginx
</code>
