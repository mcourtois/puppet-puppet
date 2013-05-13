require 'spec_helper'

package = 'puppet'
service = package
fqdn = 'agent.domain.local'
server = 'puppet.domain.local'
alt_dns_names = 'puppet'

describe 'puppet::master::certificate' do
  let(:title) { 'puppet::certificate' }
  let(:facts) { {
    :osfamily => 'Debian',
    :fqdn => fqdn
  } }

  context "class with some parameters" do 
    it { should include_class('puppet') }
    it { should create_class('puppet::master::certificate') }
    it { should create_package('puppet') }
    it { should create_exec('puppet-cert-request')\
      .with(
        'command' => /agent.*#{fqdn}/,
        'creates' => /.*#{fqdn}.pem/,
        'timeout' => '130'
      ) }
    it { should create_exec('create-ca-directory')\
      .with(
        'command' => /mkdir -p .*.ca$/,
        'creates' => /.ca$/
      ) }
    it { should create_exec('link-ca-crl')\
      .with(
        'command' => /ln -s.*crl.pem.*ca_crl.pem$/,
        'creates' => /ca.ca_crl.pem$/
      ) }
  end
end
