# === Class ssh ===
# Installs client & server ssh packages and set up the configuration.
# For non-standard (22) port it allows its usage in SELinux.
#
# === Parameters ===
# [*selinux*]
# If true and port is non-standard, then usage of this port is allowed via semanage.
#
# All the rest params are normal sshd config params described in man.
#
class ssh (
  Boolean $selinux                                     = $ssh::params::selinux,
  Numeric $port                                        = $ssh::params::port,
  Enum['any','inet','inet6'] $addressfamily            = $ssh::params::addressfamily,
  Array[Stdlib::Ip::Address] $listenaddress            = $ssh::params::listenaddress,
  Array[String] $hostkeys                              = $ssh::params::hostkeys,
  Optional[Array] $ciphers                             = undef,
  Optional[Array] $macs                                = undef,
  String $syslogfacility                               = $ssh::params::syslogfacility,
  String $sshloglevel                                  = $ssh::params::sshloglevel,
  Enum['yes','no','without-password'] $permitrootlogin = $ssh::params::permitrootlogin,
  Numeric $maxauthtries                                = $ssh::params::maxauthtries,
  Enum['yes','no'] $passwordauth                       = $ssh::params::passwordauth,
  Enum['yes','no'] $kerberosauth                       = $ssh::params::kerberosauth,
  Enum['yes','no'] $challrespauth                      = $ssh::params::challrespauth,
  Enum['yes','no'] $gssapiauth                         = $ssh::params::gssapiauth,
  Enum['yes','no'] $x11forwarding                      = $ssh::params::x11forwarding,
  Numeric $clientaliveinterval                         = $ssh::params::clientaliveinterval,
  Numeric $clientalivecountmax                         = $ssh::params::clientalivecountmax,
  Enum['yes','no'] $usedns                             = $ssh::params::usedns,
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

  if $port != 22 and $selinux {
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
