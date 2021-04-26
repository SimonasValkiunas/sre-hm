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

# install prometheus
node.override['prometheus-platform']['components']['prometheus']['install?'] = true
# install node_exporter
node.override['prometheus-platform']['components']['node_exporter']['install?'] = true

# configures node exported to listen on 9100 port
listen_ip = '127.0.0.1'
node_exporter 'main' do
  web_listen_address "#{listen_ip}:9100"
  action [:enable, :start]
end

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

# include necessary recipes
include_recipe 'prometheus-platform::default'
include_recipe 'prometheus_exporters::node'

# install and configure grafana
grafana_install 'grafana'

# grafana_plugin 'node-exporter-dashboard' do
#   action :install
#   plugin_url 'https://github.com/prometheus/node_exporter/releases/download/v1.1.1/node_exporter-1.1.1.linux-amd64.tar.gz'
# end

service 'grafana-server' do
  action [:enable, :start]
  subscribes :restart, ['template[/etc/grafana/grafana.ini]', 'template[/etc/grafana/ldap.toml]'], :delayed
end

