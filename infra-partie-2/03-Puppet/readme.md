<h1>ATELIER 3 — PUPPET : AUTOMATISATION DE LA CONFIGURATION</h1>
<h2>Étape 1 – Préparer le dossier du TP</h2>
<p>Créer un dossier afin de réaliser ce tp</p>
<h2>Étape 2 – Installer Puppet</h2>
<p>Si tu le fais dans ta VM Ubuntu (ou ton poste Linux/WSL) :</p>
<code>
sudo apt update
sudo apt install -y puppet
</code>
<p>Si tu es sur macOS : </p>
<code>brew install puppet
</code>
<p>Si tu es sur Windows via Chocolatey : </p>
<p>Installe Chocolatey si tu ne l’as pas déjà, dans un powershell :</p>
<code>
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = `
[System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
</code>
<p>Installes puppet : </p>
<code>choco install puppet-agent -y
</code>
<p>Penses à redémarrer ton powershell</p>
<p>Une fois puppet installé vérifie avec :  </p>
<code>puppet --version
</code>
<h2>Étape 3 – Créer le dossier de modules Puppet</h2>
<p>Puppet fonctionne avec une hiérarchie classique :<br/>
modules/"nom_module"/manifests/init.pp </p>
<p>Créer donc la structure de dossier et fichier comme cela avec nginx comme nom de module.</p>
<h2>Étape 4 – Écrire le manifeste Puppet</h2>
<p>Dans le fichier init.pp, vous pouvez ajouter ce contenu pour Linux (Ubuntu/Debian) :</p>
<code>
class nginx {

    package { 'nginx':
        ensure => installed,
    }

    service { 'nginx':
        ensure => running,
        enable => true,
        require => Package['nginx'],
    }

    file { '/var/www/html/index.html':
        ensure  => file,
        content => "<h1>Bienvenue sur le serveur Puppet Nginx !</h1>\n",
        require => Package['nginx'],
    }
}

</code>
<p>Si vous êtes sur macOS :</p>
<code>
class nginx {

    if $facts['os']['family'] == 'Darwin' {
        # Démo simple sur macOS : on montre que Puppet gère un fichier
        file { '/tmp/nginx-puppet.html':
            ensure  => file,
            content => "<h1>Démo Puppet macOS (fichier géré)</h1>\n",
        }
    } else {
        package { 'nginx':
        ensure => installed,
        }

        service { 'nginx':
          ensure => running,
          enable => true,
          require => Package['nginx'],
        }

        file { '/var/www/html/index.html':
          ensure  => file,
          content => "<h1>Bienvenue sur le serveur Puppet Nginx !</h1>\n",
          require => Package['nginx'],
        }
    }
}

</code>
<p>La version pour Windows :</p>
<code>
class nginx {

    if $facts['os']['family'] == 'windows' {
        file { 'C:/puppet-demo-nginx.html':
        ensure  => file,
        content => "<h1>Démo Puppet sur Windows</h1>\n",
        }
    } else {
        package { 'nginx':
        ensure => installed,
        }

        service { 'nginx':
          ensure => running,
          enable => true,
          require => Package['nginx'],
        }

        file { '/var/www/html/index.html':
          ensure  => file,
          content => "<h1>Bienvenue sur le serveur Puppet Nginx !</h1>\n",
          require => Package['nginx'],
        }
    }
}

</code>
<p>Ce qu’on fait ici :<br/>

Installe le package nginx<br/>

Démarre et active le service<br/>

Remplace la page par défaut par un message personnalisé</p>
<h2>Étape 5 – Appliquer la configuration Puppet localement</h2>
<p>Reviens à la racine du TP</p>
<p>Applique le module localement (sans serveur Puppet) :</p>
<code>sudo puppet apply --modulepath=modules -e "include nginx"
</code>
<h2>Étape 6 – Vérification</h2>
<p>Si tu es sur Linux (Ubuntu/Debian)</p>
<p>Vérifies que nginx tourne :</p>
<code>systemctl status nginx
</code>
<p>ou</p>
<code>curl http://localhost
</code>
<p>Tu dois voir ton h1 Bienvenue sur le serveur Puppet Nginx</p>
<p>Si tu es sur macOS</p>
<p>Vérifie que Puppet a bien créé le fichier :</p>
<code>cat /tmp/nginx-puppet.html
</code>
<p>Tu dois voir ton h1 Démo Puppet macOS</p>
<p>Si tu es sur Windows</p>
<p>Ouvre C:\puppet-demo-nginx.html dans le bloc-notes</p>
<p>Tu dois voir ton h1 Démo Puppet sur Windows</p>
<h2>Étape 8 — Vérifier l’idempotence</h2>
<p>C’est une notion clé de Puppet (et de la conf as code) : si l’état est déjà bon, Puppet ne doit rien faire.</p>
<p>Relance exactement la même commande que tout à l’heure :</p>
<p>Cette fois, tu dois voir 0 changement. Sur linux tu dois voir ça :</p>
<code>Notice: Applied catalog in 0.12 seconds
</code>
