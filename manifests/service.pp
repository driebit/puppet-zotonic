# Manages the Zotonic system service
class zotonic::service(
  $ensure = 'running',
  $enable = true,
) {
  case $::operatingsystem {
    'ubuntu': {
      # Taken care of by Ubuntu package
    }
    default: {
      # Create Zotonic service
      file { '/etc/init.d/zotonic':
        content => template('zotonic/service.erb'),
        mode    => 'a+x',
        require => Exec['make zotonic'],
        before  => Service['zotonic']
      }
    }
  }

  # Start Zotonic service
  service { 'zotonic':
    ensure => $ensure,
    enable => $enable,
  }
}
