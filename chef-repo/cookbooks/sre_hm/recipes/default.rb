#
# Cookbook:: sre_academy
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright:: 2021, The Authors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# install prometheus and node exporter
node.override['prometheus-platform']['components']['prometheus']['install?'] = true
node.override['prometheus-platform']['components']['node_exporter']['install?'] = true

include_recipe 'prometheus-platform::default'
include_recipe 'prometheus_exporters::node'

# configures node exported to listen on 9100 port
listen_ip = '127.0.0.1'
node_exporter 'main' do
  web_listen_address "#{listen_ip}:9100"
  action [:enable, :start]
end

# create recording rules file
include_recipe 'sre_hm::recording_rules'

# configures prometheus to scrape data from node exporter
node.override['prometheus-platform']['components']['prometheus']['config']['scrape_configs'] = {
  'index_1' =>
  {
    'job_name' => 'node',
    'scrape_interval' => '15s',
    'static_configs' => {
      'index_1' => {
        'targets' => ['localhost:9100']
      }
    }
  }
}

# install and configure grafana
grafana_install 'grafana'

service 'grafana-server' do
  action [:enable, :start]
  subscribes :restart, ['template[/etc/grafana/grafana.ini]', 'template[/etc/grafana/ldap.toml]'], :delayed
end

# create datasource for prometheus
grafana_datasource 'Prometheus' do
  datasource(
    access: "proxy",
    basicAuth: false,
    basicAuthPassword: "",
    basicAuthUser: "",
    database: "",
    id: 3,
    isDefault: true,
    jsonData: {httpMethod: "POST"},
    name: "Prometheus",
    orgId: 1,
    password: "",
    readOnly: false,
    secureJsonFields: {},
    type: "prometheus",
    typeLogoUrl: "",
    url: "http://localhost:9090",
    user: "",
    version: 1,
    withCredentials: false
  )
  action :create
end

# create dashboard file
include_recipe 'sre_hm::grafana_node_dashboard'

# load dashboard
grafana_dashboard 'node-dash' do
  dashboard(
    path: '/etc/grafana/provisioning/dashboards/node-dash.json'
  )
end
