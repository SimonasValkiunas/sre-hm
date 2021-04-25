# frozen_string_literal: true

#
# Copyright (c) 2016-2017 Sam4Mobile, 2017-2020 Make.org
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

cookbook_name = 'prometheus-platform'

# Where to get the tarball for Prometheus server
mirror = 'https://github.com/prometheus/' \
  '%<comp>s/releases/download/v%<version>s'
file = '%<comp>s-%<version>s.linux-amd64.tar.gz'

# Prometheus package and version from https://prometheus.io/download
# Set install? to true to install a component
# For each component, the url field will be added later in the file
#   'url' => url of file, default: "#{mirror}/#{file}"
default[cookbook_name]['components'] = {
  'prometheus' => {
    'install?' => false,
    'version' => '2.17.2',
    'sha' => 'a8ca17b845df4967ff5ef9f9b2c7c98568104e777c9f9a4eb1bc409726089626'
  },
  'alertmanager' => {
    'install?' => false,
    'version' => '0.20.0',
    'sha' => '3a826321ee90a5071abf7ba199ac86f77887b7a4daa8761400310b4191ab2819'
  },
  'blackbox_exporter' => {
    'install?' => false,
    'version' => '0.16.0',
    'sha' => '52d3444a518ea01f220e08eaa53eb717ef54da6724760c925ab41285d0d5a7bd'
  },
  'consul_exporter' => {
    'install?' => false,
    'version' => '0.6.0',
    'sha' => '70770e54cfdd0997f3031357ce0f45bbe16e7d1b44fc3a0771b192c5bfe1af10'
  },
  'graphite_exporter' => {
    'install?' => false,
    'version' => '0.7.0',
    'sha' => '5864e609f8cf722cdac6956e69c05aaf11582bf665934ef15a72bde938295b61'
  },
  'haproxy_exporter' => {
    'install?' => false,
    'version' => '0.10.0',
    'sha' => '08150728e281f813a8fcfff4b336f16dbfe4268a1c7510212c8cff2579b10468'
  },
  'memcached_exporter' => {
    'install?' => false,
    'version' => '0.6.0',
    'sha' => '20382d37ca99bbde2661fdbfb43a181f95d68889b761e56b39678e31bb23b64c'
  },
  'mysqld_exporter' => {
    'install?' => false,
    'version' => '0.12.1',
    'sha' => '133b0c281e5c6f8a34076b69ade64ab6cac7298507d35b96808234c4aa26b351'
  },
  'node_exporter' => {
    'install?' => false,
    'version' => '0.18.1',
    'sha' => 'b2503fd932f85f4e5baf161268854bf5d22001869b84f00fd2d1f57b51b72424'
  },
  'pushgateway' => {
    'install?' => false,
    'version' => '1.2.0',
    'sha' => 'fb64bc01078ff4af1b4677f29363209845188010ed25cef3cef9ede9646d548e'
  },
  'statsd_exporter' => {
    'install?' => false,
    'version' => '0.15.0',
    'sha' => '67b722a51fbaee80800201822aa5dd5bdb51bb5105b4ca22fc4244fa8cfb85da'
  }
}

# User and group of prometheus process
default[cookbook_name]['user'] = 'prometheus'
default[cookbook_name]['group'] = 'prometheus'

# Ark stuff (Installation), shared for all components
default[cookbook_name]['prefix_root'] = '/opt' # base installation dir
default[cookbook_name]['prefix_home'] = '/opt' # where is link to install dir
default[cookbook_name]['prefix_bin'] = '/opt/bin' # where to link binaries

# Default unit file, can be modified/extended for each component
default[cookbook_name]['default']['unit'] = {
  'Unit' => {
    'Description' => 'Prometheus platform: %<comp>s',
    'After' => 'network.target'
  },
  'Service' => {
    'Type' => 'simple',
    'User' => node[cookbook_name]['user'],
    'Group' => node[cookbook_name]['group'],
    'WorkingDirectory' => '%<path>s',
    'SyslogIdentifier' => '%<comp>s',
    'Restart' => 'on-failure',
    'ExecStart' => '%<cli>s'
  },
  'Install' => {
    'WantedBy' => 'multi-user.target'
  }
}

# Rules dir, will be created and populated by 'rules' attributes
default[cookbook_name]['components']['prometheus']['rules_dir'] = 'rules'

# Prometheus main config
default[cookbook_name]['components']['prometheus']['config'] = {
  'rule_files' => [
    "#{node[cookbook_name]['components']['prometheus']['rules_dir']}/*"
  ],
  'global' => {
    'scrape_interval' => '15s',
    'evaluation_interval' => '15s',
    'external_labels' => {
      'monitor' => 'codelab-monitor'
    }
  },
  'alerting' => {
    'alertmanagers' => [{
      'static_configs' => [{
        'targets' => ["#{node['fqdn']}:9093"]
      }]
    }]
  },
  'scrape_configs' => { # will be converted to array (see below)
    'index_1' =>
    {
      'job_name' => 'prometheus',
      'scrape_interval' => '5s',
      'static_configs' => {
        'index_1' => {
          'targets' => ['localhost:9090', 'localhost:9100']
        }
      }
    }
  }
  # this scrape_configs entry is equivalent and will be rewritten to:
  # 'scrape_configs' => [
  #   {
  #     'job_name' => 'prometheus',
  #     'scrape_interval' => '5s',
  #     'static_configs' => {
  #       'index_1' => {
  #         'targets' => ['localhost:9090', 'localhost:9100']
  #       }
  #     }
  #   }
  # ]

  # Actually, all hash containing a key 'index_xxxx' will be rewritten like
  # that. This is to permit the overriding of default values in role attribute.
}

# Scrape_configs can be configured directly in config or in the following
# attributes which will be interpreted by scraper recipe,
# using cluster-search cookbook

# First default config that will be merged in all scrapers config
default[cookbook_name]['components']['prometheus']['scrapers_default'] = {
  # Example:
  # 'relabel_configs' => [
  #    'source_labels' => ['__address__'],
  #    'regex' => '([^:]+):(.*)',
  #    'replacement' => '$1',
  #    'target_label' => 'instance'
  #  ]
}

# Then scrapers list
default[cookbook_name]['components']['prometheus']['scrapers'] = {
  # Example:
  # 'node_exporter' => {
  #   'scrape_interval' => '60s',
  #   'static_configs' => { # use cluster-search (search on a role)
  #     'role' => 'prometheus-platform',
  #     'port' => '9100'
  #   }
  # }
}

# Prometheus launch configuration, stored in systemd unit
# Use '' if no value is needed
default[cookbook_name]['components']['prometheus']['cli_opts'] = {
  'config.file' => '%<path>s/%<cfile>s',
  'storage.tsdb.path' => '/var/opt/prometheus',
  'storage.tsdb.retention.time' => '15d'
}

# Extra configuration for systemd unit, will be merged with default
default[cookbook_name]['components']['prometheus']['unit'] = {
  'Service' => {
    'LimitNOFILE' => 65_536
  }
}

# Rules configuration for Prometheus, will be in rules_dir
default[cookbook_name]['components']['prometheus']['rules'] = {
  # file => array of rules where a rule is a string, or an array of string
  # example:
  #   'alerting' => [],
  #   'recording' => []
}

# Alertmanager configuration, empty by default which is non-working
# If template's path is needed, it will be automatically added
default[cookbook_name]['components']['alertmanager']['config'] = {}

# Alertmanager alert templates configuration, empty by default
default[cookbook_name]['components']['alertmanager']['templates'] = {
  # file => string representing template content
  # example:
  #   'notification' => 'template_content'
}

# Alertmanager launch configuration, stored in systemd unit
# Use '' if no value is needed
default[cookbook_name]['components']['alertmanager']['cli_opts'] = {
  'config.file' => '%<path>s/%<cfile>s',
  'storage.path' => '/var/opt/alertmanager'
}

# Simple proc to do a deep merge on hash
deep_merge = proc do |_, old, new|
  old.respond_to?(:merge) ? old.merge(new, &deep_merge) : new
end

# Merge global default with each component default
node[cookbook_name]['components'].each_pair do |comp, config|
  default[cookbook_name]['components'][comp]['url'] = "#{mirror}/#{file}"

  default_unit = node[cookbook_name]['default']['unit'].to_h
  current_unit = config['unit'] || {}
  default[cookbook_name]['components'][comp]['unit'] =
    default_unit.merge(current_unit, &deep_merge)
end

def interpol(conf, keys)
  if conf.is_a?(String)
    conf % keys
  elsif conf.is_a?(Hash)
    conf.map { |k, v| [k, interpol(v, keys)] }.to_h
  else conf
  end
end

def opts_to_str(hash)
  (hash || {}).map { |k, v| "#{' ' * 2}--#{k}#{"=#{v}" unless v.empty?}" }
end

# Fill in previous configurations, replace %<token>s with actual value
node[cookbook_name]['components'].each_pair do |comp, config|
  path = "#{node[cookbook_name]['prefix_home']}/#{comp}"
  cfile = "#{comp}.yml"
  bin = "#{path}/#{comp}"

  keys = {
    path: path,
    cfile: cfile,
    bin: bin,
    comp: comp,
    version: config['version']
  }

  # cli need substitution too
  cli = [bin, opts_to_str(config['cli_opts'])].flatten.join(" \\\n") % keys
  keys[:cli] = cli
  default[cookbook_name]['components'][comp] = interpol(config.to_h, keys)
end

# Should we restart service after config update?
default[cookbook_name]['auto_restart'] = true

# Configure retries for the package resources, default = global default (0)
# (mostly used for test purpose
default[cookbook_name]['package_retries'] = nil
