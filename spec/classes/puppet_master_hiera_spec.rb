require 'spec_helper'

package = 'puppet'
service = package
fqdn = 'agent.domain.local'
server = 'puppet.domain.local'
    permissions = {
      :owner => 'puppet',
      :group => 'puppet',
      :mode  => '0600'
    }
hiera_yaml_content = '---
:backends:
  - yaml
:hierarchy:
  - defaults
  - %{::fqdn}
  - %{::environment}
  - policy

:yaml:
# datadir is empty here, so hiera uses its defaults:
# - /var/lib/hiera on *nix
# - %CommonAppData%\PuppetLabs\hiera\var on Windows
# When specifying a datadir, make sure the directory exists.
  :datadir: /etc/puppet/hieradata
'

describe 'puppet::master::hiera' do
  let(:title) { 'puppet::master::hiera' }

  context "class" do
    let(:facts) { {
      :osfamily => 'Debian',
      :fqdn => fqdn
    } }

    it { should create_class('puppet::master::hiera') }
    it { should create_package('hiera')\
      .with( :ensure => :present) }
    it { should create_file('/etc/puppet/hieradata')\
      .with(permissions.merge({ :ensure => :directory }) ) }
    it { should create_file('/etc/puppet/hiera.yaml')\
      .with(permissions.merge( {
        :ensure => :present,
        :content => hiera_yaml_content
        } ) ) }
  end

  context "class with parameters" do
    let(:params) { {
      :ensure => 'latest',
      :hieraconfig_content => 'my awesome content'
    } }
    let(:facts) { {
      :osfamily => 'Debian',
      :fqdn => fqdn
    } }
    it { should create_class('puppet::master::hiera') }
    it { should create_file('/etc/puppet/hieradata')\
      .with(permissions.merge({ :ensure => :directory }) ) }
    it { should create_file('/etc/puppet/hiera.yaml')\
      .with(permissions.merge(
        { :content => 'my awesome content' }
      ))}
    it { should create_package('hiera')\
      .with( :ensure => :latest) }
  end
end
