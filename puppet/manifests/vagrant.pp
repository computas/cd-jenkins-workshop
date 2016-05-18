# -OS-BASICS-------------------------------------------------------------------
# Update the index
exec { 'apt-update':                    
  command => '/usr/bin/apt-get update'  
}

# timezone 
file { '/etc/timezone':
    ensure => present,
    content => "Europe/Oslo\n",
}

exec { 'reconfigure-timezone':
        user => root,
        group => root,
        command => '/usr/sbin/dpkg-reconfigure --frontend noninteractive tzdata',
        require => [File['/etc/timezone'], Exec['apt-update']],
}

# -GIT-------------------------------------------------------------------------
# install and configure git

/*
include git

git::config { 'user.name':
  value   => 'Michael Gfeller',
  user    => 'vagrant',
  require => Class['git'],
}

git::config { 'user.email':
  value   => 'mgfeller@mgfeller.net',
  user    => 'vagrant',
  require => Class['git'],
}

git::config { 'core.autocrlf':
  value   => 'input',
  user    => 'vagrant',
  require => Class['git'],
}

git::config { 'core.editor':
  value   => 'vim',
  user    => 'vagrant',
  require => Class['git'],
}
*/

# -TOOLS-----------------------------------------------------------------------
# install unzip
package { 'unzip':
  require => Exec['apt-update'],
  ensure => installed,
}

# install ncftp - ftp client
/*
package { 'ncftp':
  require => Exec['apt-update'],
  ensure => installed,
}
*/

# -VIM-------------------------------------------------------------------------
# install spf13-vim
/*
exec { 'install spf13-vim':
    environment => ['HOME=/home/vagrant'],
    command => '/usr/bin/curl http://j.mp/spf13-vim3 -L -o - | sh',
    cwd => '/home/vagrant/',
    creates => '/home/vagrant/.spf13-vim-3',
    require => Package['git'],
}

package { 'vim-nox':
  require => Exec['apt-update'],
  ensure => installed,
}

file { '/home/vagrant/.vimrc.local':
    ensure => 'present',
    owner  => vagrant,
    group  => vagrant,    
    mode => 664,    
    source => 'puppet:///modules/vim/.vimrc.local',
    require => Exec['install spf13-vim'],    
}

file { '/home/vagrant/.vim/syntax':
    owner  => vagrant,
    group  => vagrant,    
    mode => 755,
    ensure => 'directory',
    require => Exec['install spf13-vim'],
}

file { '/home/vagrant/.vim/syntax/asciidoc.vim':
    ensure => 'present',
    owner  => vagrant,
    group  => vagrant,
    mode => 664,    
    source => 'puppet:///modules/vim/asciidoc.vim',
    require => [File['/home/vagrant/.vim/syntax'], Exec['install spf13-vim'] ],
}
*/

# -SSH-------------------------------------------------------------------------

ssh_keygen { 'vagrant': }

# -JAVA------------------------------------------------------------------------
# install java
# this installs openjdk-7-jdk on Trusty
include java

# -VAGRANT USER----------------------------------------------------------------
# bin folder
file { '/home/vagrant/bin/':
  owner  => vagrant,
  group  => vagrant,    
  mode => 755,
  ensure => 'directory',
}

# shell configuration
/*
file { '/home/vagrant/.profile':
  owner  => vagrant,
  group  => vagrant,    
  mode => 664,
  ensure => 'present',
  source => 'puppet:///modules/shell/.profile',
}
*/

# install maven
/*
file { '/home/vagrant/bin/maven-3.3.9':
  owner  => vagrant,
  group  => vagrant,    
  mode => 664,
  ensure => 'present',
  source => 'puppet:///modules/maven/maven-3.3.9/',
  recurse => true,
  require => File['/home/vagrant/bin/'],
}
*/

# make mvn executable
/*
file { '/home/vagrant/bin/maven-3.3.9/bin/mvn':
  ensure  => 'present',
  mode    => '0755',
  owner    => 'vagrant',
  source => 'puppet:///modules/maven/maven-3.3.9/bin/mvn',
  require => File['/home/vagrant/bin/maven-3.3.9'],
}
*/

# -JENKINS---------------------------------------------------------------------
# prepare apt: install key
exec { 'install-jenkins-apt-key':
    command => "wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -",
    path    => '/usr/local/bin/:/usr/bin/:/bin/',
}

# prepare apt: download sources list
exec { 'download-jenkins-apt-sources-list-update':
    command => "sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list' && apt-get update",
    path    => '/usr/local/bin/:/usr/bin/:/bin/',
    require => Exec['install-jenkins-apt-key'],
}

# install jenkins
package { 'jenkins':
  require => Exec['download-jenkins-apt-sources-list-update'],
  ensure => latest,
}

service { 'jenkins':
  enable => true,
  ensure => running,
  require => Package['jenkins'],
}
