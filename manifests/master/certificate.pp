# === Class: puppet::master::certificate
class puppet::master::certificate (
  $waitforcert = '10',
) {
  include puppet
  $wait = "--waitforcert ${waitforcert}"
  $dns_alt_names = $puppet::agent_options['dns_alt_names']
  $command = "/usr/bin/puppet agent --ca_server ${puppet::ca_server} --server ${puppet::ca_server} --dns_alt_names ${dns_alt_names} --onetime --no-daemonize --noop"

  $puppet_ssl = $::settings::ssldir

  Package['puppet']->
  Notify['about-to-send-csr']->
  Exec['puppet-cert-request']->
  Exec['create-ca-directory']->
  Exec['link-ca-crl']

  notify { 'about-to-send-csr':
    message => "Requesting certificate signature on the CA. You have ${waitforcert} seconds to go sign the request with --allow-dns-alt-names.",
  }

  exec { 'puppet-cert-request':
    command   => "${command} ${wait} ${puppet::certname}",
    creates   => "${puppet_ssl}/certs/${puppet::certname}.pem",
    timeout   => $waitforcert + 120,
    logoutput => true,
  }

  exec { 'create-ca-directory':
    command => "/bin/mkdir -p ${puppet_ssl}/ca",
    creates => "${puppet_ssl}/ca",
  }

  exec { 'link-ca-crl':
    command => '/bin/ln -s ../crl.pem ./ca/ca_crl.pem',
    creates => "${puppet_ssl}/ca/ca_crl.pem",
    cwd     => $puppet_ssl,
  }
}


