# Cookbook:: sre_academy
# Recipe:: prometheus
# Recipe:: to install and configure Prometheus

# install prometheus
node.override['prometheus-platform']['components']['prometheus']['install?'] = true
node.override['prometheus-platform']['components']['node_exporter']['install?'] = true

# configures prometheus to scrape data from node exporter
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

include_recipe 'prometheus-platform::default'

# create recording rules file
include_recipe 'sre_hm::recording_rules'
