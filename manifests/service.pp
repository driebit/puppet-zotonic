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
        before  => Service[$zotonic::service]
      }
    }
  }

  # Start Zotonic service
  service { $zotonic::service:
    ensure => $ensure,
    enable => $enable,
    require => Exec['make zotonic'],
  }
}
