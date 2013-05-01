require 'spec_helper'

package = 'puppet'
service = package
fqdn = 'agent.domain.local'
server = 'puppet.domain.local'

describe 'puppet::agent' do
  let(:title) { 'puppet::agent' }

  ['Debian', 'RedHat'].each do |osfamily|
    context "class with some parameters on #{osfamily}" do 
      let(:params) { {
        :certname => fqdn,
        :server   => server
      } }
      let(:facts) { {
        :osfamily => osfamily,
        :fqdn => fqdn
      } }

      it { should create_class('concat::setup') }
      it { should create_class('puppet::agent') }
      it { should create_class('puppet::agent::config') }
      it { should create_concat('/etc/puppet/puppet.conf') }
      it { should create_package(package).with_ensure('present') }
      it { should create_concat__fragment('puppet_main_conf')\
           .with_content(/\[main\]/) }
      it { should create_concat__fragment('puppet_certname')\
           .with_content(/certname = #{fqdn}/) }
      it { should create_concat__fragment('puppet_agent_conf')\
           .with_content(/server      = #{server}/) }
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
  context "class with $options parameters on Debian" do 
    let(:params) { {
      :certname => fqdn,
      :server   => server,
      :options  => {
        'runinterval' => '900',
        'splay' => 'true'
      }
    } }
    let(:facts) { {
      :osfamily => 'Debian',
      :fqdn => fqdn
    } }

    it { should create_class('puppet::agent') }
    it { should create_class('puppet::agent::config') }
    it { should create_concat('/etc/puppet/puppet.conf') }
    it { should create_concat__fragment('puppet_agent_conf')\
         .with_content(/runinterval = 900/)\
         .with_content(/splay = true/) }
  end
end
