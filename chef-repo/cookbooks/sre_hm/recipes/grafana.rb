# Cookbook:: sre_academy
# Recipe:: grafana
# Recipe:: to install and configure Grafana

# install and configure grafana
grafana_install 'grafana'

service 'grafana-server' do
  action [:enable, :start]
  subscribes :restart, ['template[/etc/grafana/grafana.ini]', 'template[/etc/grafana/ldap.toml]'], :delayed
end

# create datasource for prometheus
grafana_datasource 'Prometheus' do
  datasource(
    access: 'proxy',
    basicAuth: false,
    basicAuthPassword: '',
    basicAuthUser: '',
    database: '',
    id: 3,
    isDefault: true,
    jsonData: { httpMethod: 'POST' },
    name: 'Prometheus',
    orgId: 1,
    password: '',
    readOnly: false,
    secureJsonFields: {},
    type: 'prometheus',
    typeLogoUrl: '',
    url: 'http://localhost:9090',
    user: '',
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
