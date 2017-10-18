#
class ssh::params {

  case $::osfamily {
    'redhat': {
      $server_package_name = 'openssh-server'
      $client_package_name = 'openssh-clients'
      $server_config_file  = '/etc/ssh/sshd_config'
      $client_config_file  = '/etc/ssh/ssh_config'
      $policy_package_name = 'policycoreutils-python'
      $service_name        = 'sshd'
      if $::operatingsystemmajrelease == '7' {
        $hostkeys = ['ssh_host_rsa_key','ssh_host_ecdsa_key','ssh_host_ed25519_key']
      }
      elsif $::operatingsystemmajrelease == '6' {
        $hostkeys = ['ssh_host_rsa_key','ssh_host_dsa_key']
      }
      else {
        fail('Sorry! Your version of OS is not supported')
      }
      $osversion = $::operatingsystemmajrelease
    }
    default: {
      fail('Sorry! Your OS is not supported')
    }
  }
  $selinux             = $facts['os']['selinux']['enabled']
  $port                = 22
  $addressfamily       = 'any' # can be any, inet, inet6
  $listenaddress       = ['0.0.0.0', '::']
  $syslogfacility      = 'AUTHPRIV'
  $sshloglevel         = 'INFO'
  $permitrootlogin     = 'yes'
  $maxauthtries        = 6
  $passwordauth        = 'yes'
  $kerberosauth        = 'no'
  $challrespauth       = 'no'
  $gssapiauth          = 'no'
  $x11forwarding       = 'yes'
  $clientaliveinterval = 3
  $clientalivecountmax = 0
  $usedns              = 'yes'
}
