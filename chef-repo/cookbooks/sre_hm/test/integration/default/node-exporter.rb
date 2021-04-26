# InSpec test for recipe sre_hm::node-exporter

# The InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

control 'node_exporter' do
  impact 1.0
  title 'node_exporter service should be installed and running'
  desc 'node_exporter should be installed and running'

  describe service('node_exporter') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
