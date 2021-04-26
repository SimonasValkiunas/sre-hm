# Cookbook:: sre_academy
# Recipe:: node-exporter
# Recipe to install and configure node-exporter

# configures node exported to listen on 9100 port
listen_ip = '127.0.0.1'
node_exporter 'main' do
  web_listen_address "#{listen_ip}:9100"
  action [:enable, :start]
end

include_recipe 'prometheus_exporters::node'
