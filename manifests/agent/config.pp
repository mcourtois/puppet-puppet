# === Class: puppet::agent::config
class puppet::agent::config ($options = undef) {
  # Note that puppet agent or master are restarted if needed
  concat::fragment {'puppet_main_conf':
    target  => '/etc/puppet/puppet.conf',
    content => template('puppet/puppet_main_conf.erb'),
    order   => '10',
  } ~>
  Service <| tag == 'puppetconf' |>

  concat::fragment { 'puppet_certname':
    target  => '/etc/puppet/puppet.conf',
    content => "certname = ${puppet::agent::certname}\n",
    order   => '20',
  } ~>
  Service <| tag == 'puppetconf' |>

  concat::fragment { 'puppet_agent_conf':
    target  => '/etc/puppet/puppet.conf',
    content => template('puppet/puppet_agent_conf.erb'),
    order   => '30',
  } ~>
  Service <| tag == 'puppet' |>

  if $::osfamily == 'Debian' {
    file { '/etc/default/puppet':
      ensure  => present,
      content => template('puppet/default.erb')
    }
  }
}
