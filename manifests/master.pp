# == Class: puppet::master
# This class manage the puppet master configuration and service.
# It is not meant to be called directly. Use the puppet class instead.
#
# === Parameters
# The following parameters are different from the puppet class:
#
# [*hieraconfig*]
#   A source of your hiera.yaml configuration file. Defaults to 'puppet:///modules/puppet/hiera.yaml'.
#
# [*options*]
#   Will apply master_options from the puppet class.
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
class puppet::master(
  $autosign=[],
  $passenger=false,
  $certname=$::fqdn,
  $puppetdb=false,
  $hieraconfig=undef,
  $ca=true,
  $options=undef,
){
  include puppet::params
  include puppet::config

  if $passenger {
    $puppetmaster = 'puppetmaster-passenger'
    package { 'puppetmaster':
      ensure => absent,
    }
  } else {
    $puppetmaster = 'puppetmaster'
    package { 'puppetmaster-passenger':
      ensure => absent,
    }
  }

  if $ca == false {
    Class['puppet::master::certificate']->
    Package[$puppetmaster]

    include puppet::master::certificate
  }

  $service_name = $passenger ? {
    true    => $puppet::params::passenger_service,
    false   => 'puppetmaster',
    default => fail('$passenger is true or false'),
  }

  package { $puppetmaster:
    ensure => present,
  }

  include puppet::master::service

  # Client configuration should be done before the puppetmaster is
  # launched a first time, so certificates are correctly generated.
  anchor { 'puppet::master::begin': } ->
  Concat['/etc/puppet/puppet.conf']->
  File['/var/lib/puppet/reports']->
  Package[$puppetmaster]->
  Class['puppet::master::hiera']~>
  Service[$service_name] ->
  anchor { 'puppet::master::end': }

  concat::fragment { 'puppet_master_conf':
    target  => '/etc/puppet/puppet.conf',
    content => template('puppet/puppet_master_conf.erb'),
    order   => '40',
  } ~>
  Service[$service_name]

  # We want to make sure that the puppetdb service doesn't start
  # before the puppetmaster.
  Package[$puppetmaster] -> Package <| tag == 'puppetdb' |>

  # Autosign since we don't want to manage certificate at this point
  class { 'puppet::master::autosign':
    autosign => $autosign,
  }

  class { 'puppet::master::hiera':
    hieraconfig => $hieraconfig,
  }

  file { '/var/lib/puppet/reports':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0640',
  }

}
