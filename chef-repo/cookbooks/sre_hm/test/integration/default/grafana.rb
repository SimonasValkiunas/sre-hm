# InSpec test for recipe sre_hm::grafana

# The InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

control 'grafana-server' do
  impact 1.0
  title 'grafana-server service should be installed and running'
  desc 'grafana-server should be installed and running'

  describe service('grafana-server') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
