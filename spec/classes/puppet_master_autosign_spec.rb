require 'spec_helper'

package = 'puppet'
service = package
fqdn = 'agent.domain.local'
server = 'puppet.domain.local'
autosign = ['*']

describe 'puppet::master::autosign' do
  let(:title) { 'puppet::master::autosign' }

  context "class" do 
    let(:params) { {
      :autosign => autosign
    }}

    let(:facts) { {
      :osfamily => 'Debian',
      :fqdn => fqdn
    } }

    it { should create_class('puppet::master::autosign') }
    it { should create_file('/etc/puppet/autosign.conf')\
      .with(
        :owner => 'puppet',
        :group => 'puppet',
        :mode  => '0600',
        :ensure => :present
        )\
      .with_content("*\n") }
  end
  context "class with wrong autosign param" do 
    let(:params) { {
      :autosign => 'true'
    }}

    let(:facts) { {
      :osfamily => 'Debian',
      :fqdn => fqdn
    } }

    it { expect { should create_class('puppet::master::autosign') }.to\
      raise_error(Puppet::Error, /is not an Array/) }
  end
end
