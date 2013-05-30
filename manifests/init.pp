# == Class: puppet
#
# This class will configure the puppet agent and optionnaly the puppet
# server. The puppet server will managed through puppet.
#
# === Parameters
#
# Most of the parameters have the same name than the puppet option. Look at the
# puppet documentation for more details.
#
# [*certname*]
#   Will be used by both agent and server. Defaults to `$::fqdn`. You can
#   also set alt_dns_names for the server name if you want other names.
#
# ==== Agent parameters
#
# [*server*]
#   Which server will be used by the agent. Defaults to 'puppet'
#
# ==== Master parameters
#
# [*master*]
#   Whether the puppetmaster will be installed or not.
# [*passenger*]
#   Whether the puppetmaster will be running using passenger and apache or
#   webrick.
# [*autosign*]
#   Whether the puppet master will sign automatically the agents CSR. Mostly
#   for testing, don't use that feature in production.
# [*puppetdb*]
#   Whether the puppet master will use puppetdb for storeconfigs. You need to
#   setup puppetdb separately using the puppetdb module from PuppetLabs.
#
# === Examples
#
#  class { 'puppet':
#    certname => 'somehost.somedomain.tld',
#    server   => 'puppetmaster.somedomain.tld',
#  }
#
# === Author
#
# Simon Piette <simon.piette@savoirfairelinux.com>
#
# === Copyright
#
# Copyright 2013 Simon Piette <simon.piette@savoirfairelinux.com>
# Apache 2.0 Licence
#
class puppet (
  $certname=$::fqdn,
  $server='puppet',
  $master=false,
  $agent_options=undef,
  $master_options=undef,
  $ca=true,
  $ca_server=undef,
  $hieraconfig_content=undef,
  $passenger=false,
  $puppetdb=false,
  $autosign=[],
  $ensure='present',
) {

  include puppet::config
  anchor { 'puppet::begin': } ->
  class { 'puppet::agent':
    server    => $server,
    certname  => $certname,
    ca_server => $ca_server,
    options   => $agent_options,
    ensure    => $ensure,
  }

  if $master {
    class { 'puppet::master':
      ca                  => $ca,
      autosign            => $autosign,
      passenger           => $passenger,
      certname            => $certname,
      puppetdb            => $puppetdb,
      options             => $master_options,
      hieraconfig_content => $hieraconfig_content,
      ensure              => $ensure,
    } -> anchor { 'puppet::end': }
  } else {
    Class['puppet::agent'] -> anchor { 'puppet::end': }
  }
}
