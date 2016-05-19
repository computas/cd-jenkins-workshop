# -OS-BASICS-------------------------------------------------------------------
# Update the index
exec { 'apt-update':                    
  command => '/usr/bin/apt-get -y -q update'  
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
# install and optionally configure git

/*
include git

git::config { 'user.name':
  value   => 'Roaming Vagrant',
  user    => 'vagrant',
  require => Class['git'],
}

git::config { 'user.email':
  value   => 'vagrant@localhost',
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

# No OpenJDK 8 on Trusty, so we install Oracle JDK 7 and 8, and set JDK 8 as default
exec {'prepare-oracle-jdk-installation':
    command => "apt-get -y -q install software-properties-common htop && add-apt-repository -y ppa:webupd8team/java && apt-get -y -q update",
    path    => '/usr/local/bin/:/usr/bin/:/bin/',    
}

exec {'accept-oracle-jdk7-license':
    command => "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections",
    require => Exec['prepare-oracle-jdk-installation'],
    path    => '/usr/local/bin/:/usr/bin/:/bin/',    
}

exec {'accept-oracle-jdk8-license':
    command => "echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections",
    require => Exec['prepare-oracle-jdk-installation'],
    path    => '/usr/local/bin/:/usr/bin/:/bin/',    
}

package { 'oracle-java8-installer':
  ensure => 'installed',
  require => Exec['accept-oracle-jdk8-license'],
}

package { 'oracle-java7-installer':
  ensure => 'installed',
  require => Exec['accept-oracle-jdk7-license'],
}

exec {'set-default-jdk':
    command => "/usr/sbin/update-java-alternatives -s java-8-oracle",
    require => Package['oracle-java8-installer'],
    path    => '/usr/local/bin/:/usr/bin/:/bin/:/usr/sbin/',    
}

# -VAGRANT USER----------------------------------------------------------------
# bin folder
file { '/home/vagrant/bin/':
  owner  => vagrant,
  group  => vagrant,    
  mode => 755,
  ensure => 'directory',
}

# shell configuration
file { '/home/vagrant/.profile':
  owner  => vagrant,
  group  => vagrant,    
  mode => 664,
  ensure => 'present',
  source => 'puppet:///modules/shell/.profile',
}

# -MAVEN-----------------------------------------------------------------------
file { '/usr/share/maven/':
  owner  => root,
  group  => root,    
  mode => 755,
  ensure => 'directory',
}

file { '/usr/share/maven/maven-3.3.9':
  owner  => root,
  group  => root,    
  mode => 664,
  ensure => 'present',
  source => 'puppet:///modules/maven/maven-3.3.9/',
  recurse => true,
  require => File['/usr/share/maven/'],
}

# make mvn executable
file { '/usr/share/maven/maven-3.3.9/bin/mvn':
  ensure  => 'present',
  mode    => '0755',
  owner    => 'root',
  source => 'puppet:///modules/maven/maven-3.3.9/bin/mvn',
  require => File['/usr/share/maven/maven-3.3.9'],
}

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
  ensure => installed,
}

service { 'jenkins':
  enable => true,
  ensure => running,
  require => Package['jenkins'],
}

# -MAIL------------------------------------------------------------------------
# postfix is already installed
package { 'mailutils':
  require => Exec['apt-update'],
  ensure => installed,
}

exec { 'setup-vagrant-mail':
    command => "sudo adduser vagrant mail && sudo touch /var/mail/vagrant && sudo chown vagrant:mail /var/mail/vagrant && sudo chmod ug+rw /var/mail/vagrant",
    path    => '/usr/local/bin/:/usr/bin/:/bin/',
}
