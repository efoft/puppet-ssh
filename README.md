# puppet-ssh
Installs both ssh server and client. Configures ssh server.

## Installation
Clone into puppet's modules directory:
```
git clone git@github.com:efoft/puppet-ssh.git ssh
```

## Usage

Example:
```
class { 'ssh':
    permitrootlogin     => 'no'
    maxauthtries        => '3',
    x11forwarding       => 'yes',
    clientaliveinterval => '300',
    clientalivecountmax => '36',
    usedns              => 'no'
  }
```
