# == Class role::puppetmaster
# Example puppemaster role
#
# Needed modules (Puppetfile format) apart this puppet module.
#
# forge "http://forge.puppetlabs.com"
# mod 'puppetlabs/stdlib'
# mod 'ripienaar/concat'
# mod 'puppetlabs/apt'
# mod 'puppetlabs/firewall'
# mod 'puppetlabs/apache'
# mod 'cprice404/inifile'
# mod 'puppetlabs/postgresql'
# mod 'puppetlabs/puppetdb'
#
# The puppetdb package is really keen to have bad certficates if your fqdn !=
# certname Run puppet twice to correct this. One run will suffice for cases
# when fqdn == certname
#
# You can renamed this file to ${modulepath}/role/manifests/puppetmaster.pp (or
# rename the class to your liking) and include it in your node declaration.
class role::puppetmaster(
  $ip = $::ipaddress_eth0,
  $master_certname = 'puppet.local.lan',
  $passenger = true,
  $puppetdb = true,
){
  $puppet_service_name = $passenger ? {
    true  => 'apache2',
    false => 'puppetmaster',
  }
  #APT repo
  class { 'apt': }

  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com',
    repos      => 'main',
    key        => '4BD6EC30',
    key_server => 'pgp.mit.edu',
  }

  Class['Apt::Update'] -> Package <| |>

  host { $::fqdn:
    host_aliases => [ $::hostname, $master_certname ],
    ip           => $ip
  }

  class { 'puppet':
    certname  => $master_certname,
    server    => $master_certname,
    master    => true,
    puppetdb  => $puppetdb,
    passenger => $passenger,
  }

  Host[$::fqdn] ->
  Class['puppet']->
  Class['puppetdb']

  Service['puppet']->
  Package['puppetmaster-passenger']->
  Package['puppetdb']

  # This is hack to get the run in one shot
  Ini_setting['puppetdb_sslhost', 'puppetdb_sslport']~>
  Service['puppetdb']
  # Puppetdb_conn_validator[puppetdb_conn]
  # Puppetdb_conn_validator[puppetdb_conn]

  #Puppetdb
  class { 'puppetdb':
    database           => embedded,
    ssl_listen_address => $master_certname,
  }

  class {'puppetdb::master::config':
    puppet_service_name      => $puppet_service_name,
    puppetdb_startup_timeout => '30',
  }
}
