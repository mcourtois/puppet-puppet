# == Class: puppet::agent
# This class manage the puppet agent configuration and service.
# It is not meant to be called directly. Use the puppet class instead.
#
# === Parameters
# The following parameters are different from the puppet class:
#
# [*environment*]
#   Set the environment under which the agent will run.
#
# [*options*]
#   Will apply agent_options from the puppet class.
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
class puppet::agent (
  $server = 'puppet',
  $ca_server = undef,
  $environment = 'production',
  $certname = $::fqdn,
  $options = undef,
  ){
  anchor { 'puppet::agent::begin': }->
  Package['puppet']->
  Class['puppet::agent::config']~>
  Service['puppet']->
  anchor { 'puppet::agent::end': }

  include concat::setup
  include puppet::config
  class { 'puppet::agent::config':
    options => $options,
  }

  package { 'puppet':
    ensure => present
  }

  service { 'puppet':
    ensure  => running,
    enable  => true,
    tag     => 'puppetconf',
  }
}
