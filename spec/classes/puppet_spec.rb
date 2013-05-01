require 'spec_helper'

package = 'puppet'
service = package
fqdn = 'agent.domain.local'
server = 'puppet.domain.local'

describe 'puppet' do
  let(:title) { 'puppet' }

  ['Debian', 'RedHat'].each do |osfamily|
    context "class with some parameters on #{osfamily}" do 
      let(:params) { {
        :certname => fqdn,
        :server   => server,
        :master => 'true',
        :agent_options => { 'splay' => 'true' },
        :master_options => { 'environment' => 'stage' }
      } }
      let(:facts) { {
        :osfamily => osfamily,
        :fqdn => fqdn
      } }

      it { should create_class('puppet') }
      it { should create_class('puppet::config') }
      it { should create_class('concat::setup') }
      it { should create_class('puppet::agent') }
      it { should create_class('puppet::agent::config') }
      it { should create_class('puppet::master') }
      it { should create_concat('/etc/puppet/puppet.conf') }
      it { should create_package(package).with_ensure('present') }
      it { should create_concat__fragment('puppet_main_conf')\
           .with_content(/\[main\]/) }
      it { should create_concat__fragment('puppet_certname')\
           .with_content(/certname = #{fqdn}/) }
      it { should create_concat__fragment('puppet_agent_conf')\
           .with_content(/server      = #{server}/)\
           .with_content(/splay = true/) }
      it { should create_concat__fragment('puppet_master_conf')\
           .with_content(/environment = stage/) }
      it { should create_service(service)\
           .with(
            'ensure' => 'running',
            'enable' => 'true',
            'tag'    => 'puppetconf'
           ) }
      if osfamily == 'Debian'
        it { should create_file('/etc/default/puppet')\
          .with_content(/^START=yes$/) }
      end
    end
  end
end
