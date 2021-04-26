This is a cookbook from Vinted Academy, DevOps/SRE homework assignment

## Assignment write-up

#### Installing and configuring Prometheus and Node exporter 
I use prometheus [cookbook](https://supermarket.chef.io/cookbooks/prometheus-platform) to install both prometheus platform and node exporter
by overriding attributes in prometheus.rb recipe:
```
node.override['prometheus-platform']['components']['prometheus']['install?'] = true
node.override['prometheus-platform']['components']['node_exporter']['install?'] = true
```
Simillary, I configure prometheus to listen to node exporter:
```
node.override['prometheus-platform']['components']['prometheus']['config']['scrape_configs'] = {
  'index_1' =>
  {
    'job_name' => 'node',
    'scrape_interval' => '15s',
    'static_configs' => {
      'index_1' => {
        'targets' => ['localhost:9100'],
      },
    },
  },
}
```
In node-exporter.rb I start node_exporter service on port 9100:

```
listen_ip = '127.0.0.1'
node_exporter 'main' do
  web_listen_address "#{listen_ip}:9100"
  action [:enable, :start]
end
```
I user recording_rules.rb to create a file with recording rules taken from [here](https://grafana.com/oss/prometheus/exporters/node-exporter/?tab=recording-rules)

#### Installing and configuring Grafana
I install Grafana using [cookbook](https://supermarket.chef.io/cookbooks/grafana) and use grafana_node_dashboard.rb to create a json file for node exporter dashboard. To create datasource I use this snippet with field taken from POST request to `localhost:3000//api/datasources`:
```
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
```

#### Dashboard

![image](https://user-images.githubusercontent.com/36266354/116129607-f9400f00-a6d2-11eb-805e-71afe07cd266.png)

#### Testing

###### Scripts
I've written 3 simple test for this cookbook to check if Prometheus, Node exporter and Grafana are installed an running.
Test script for prometheus:
```
control 'prometheus' do
  impact 1.0
  title 'prometheus service should be installed and running'
  desc 'prometheus service should be installed and running'

  describe service('prometheus') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end
```
Tests for Node exporter and Grafana uses same template.

###### Results

Using `kitchen test`:

![image](https://user-images.githubusercontent.com/36266354/116130293-ba5e8900-a6d3-11eb-8d9a-c22f44640e1e.png)

Using `cookstyle .`

![image](https://user-images.githubusercontent.com/36266354/116130563-0d384080-a6d4-11eb-8a80-d860e0d257af.png)

Using `foodcritic .`:

I've not testing using foodcritic as I get error message that foodcritic has been depricated and I should use cookstyle instead.
![image](https://user-images.githubusercontent.com/36266354/116130973-7cae3000-a6d4-11eb-99d6-e4c9b4ad2299.png)

#### Dependency management

For dependency management I use Policyfiles. I've included them in [Chef repository](https://github.com/SimonasValkiunas/sre-hm_dev/tree/main/chef-repo) for this project.

Policyfile.rb:
```
name "Policyfile"

default_source :supermarket, "https://supermarket.chef.io"

cookbook 'prometheus_exporters', '~> 0.17.2', :supermarket
cookbook 'prometheus-platform', '~> 2.2.0', :supermarket
cookbook 'grafana', '~> 8.8.0', :supermarket
cookbook "sre_hm", path: "../cookbooks/sre_hm"

run_list "sre_hm"
```

#### Parent Chef Repository

Parent chef repository can be found [here](https://github.com/SimonasValkiunas/sre-hm_dev/tree/main/chef-repo)
