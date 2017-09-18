#
class ssh (
  $selinux             = $ssh::params::selinux,
  $addressfamily       = $ssh::params::addressfamily,
  $listenaddress       = $ssh::params::listenaddress,
  $hostkeys            = $ssh::params::hostkeys,
  $ciphers             = undef,
  $macs                = undef,
  $syslogfacility      = $ssh::params::syslogfacility,
  $sshloglevel         = $ssh::params::sshloglevel,
  $permitrootlogin     = $ssh::params::permitrootlogin,
  $maxauthtries        = $ssh::params::maxauthtries,
  $passwordauth        = $ssh::params::passwordauth,
  $kerberosauth        = $ssh::params::kerberosauth,
  $challrespauth       = $ssh::params::challrespauth,
  $gssapiauth          = $ssh::params::gssapiauth,
  $x11forwarding       = $ssh::params::x11forwarding,
  $clientaliveinterval = $ssh::params::clientaliveinterval,
  $clientalivecountmax = $ssh::params::clientalivecountmax,
  $usedns              = $ssh::params::usedns,
) inherits ssh::params {

  package { [
    $ssh::params::server_package_name,
    $ssh::params::client_package_name
  ]:
    ensure => latest,
  }

  file { $ssh::params::client_config_file:
    ensure  => file,
    content => template('ssh/ssh_config.erb'),
  }
  
  file { $ssh::params::server_config_file:
    ensure  => file,
    content => template('ssh/sshd_config.erb'),
    notify  => Service[$ssh::params::service_name],
  }

  if $port != '22' and $selinux {
    ensure_packages($ssh::params::policy_package_name, { 'ensure' => 'present' })

    exec { "change-ssh-port-to-${port}":
      command => "semanage port -a -t ssh_port_t -p tcp ${port}",
      path    => ['/usr/sbin','/sbin','/usr/bin','/bin'],
      unless  => "semanage port -l | grep ssh_port_t | egrep 'tcp(\s)+${port}\$'",
      require => Package[$ssh::params::policy_package_name],
    }
  }
  
  service { $ssh::params::service_name:
    ensure  => running,
    enable  => true,
    require => Package[$ssh::params::server_package_name],
  }
}
