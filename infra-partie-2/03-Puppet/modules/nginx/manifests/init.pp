class nginx {

  if $facts['os']['family'] == 'Darwin' {
    # Sur macOS, on se contente de démontrer la gestion de fichiers
    file { '/tmp/nginx-puppet.html':
      ensure  => file,
      content => "<h1>Démo Puppet macOS (pas d'installation de paquets)</h1>\n",
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
