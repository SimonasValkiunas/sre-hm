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

require 'yaml'

# Convert hash entry when key is named 'index_.*' to an array item
def h_to_a(obj) # rubocop:disable Metrics/AbcSize
  if obj.is_a?(Hash)
    obj =
      if obj.keys.map { |k| !k.to_s.start_with?('index_') }.any? || obj.empty?
        obj.map { |k, v| [k, h_to_a(v)] }.to_h
      else
        obj.values
      end
  end
  obj.is_a?(Array) ? obj.map { |v| h_to_a(v) } : obj
end

# Simplified deep merge
merge_proc = proc do |_, old, new|
  if old.respond_to?(:merge)
    old.merge(new, &merge_proc)
  elsif old.is_a?(Array)
    old + new
  else
    new
  end
end

# Write alertmanager alerts templates
templates = node[cookbook_name]['components']['alertmanager']['templates']
templates_list = []
templates.each_pair do |file, template_content|
  template_file =
    "#{node[cookbook_name]['prefix_home']}/alertmanager/#{file}.tmpl"
  file template_file do
    mode '0644'
    content template_content
    notifies(
      :reload_or_try_restart, 'systemd_unit[alertmanager.service]', :delayed
    )
  end
  templates_list << template_file
end

# Add templates paths to alertmanager configuration file
if templates_list.any?
  node.run_state[cookbook_name] ||= {}
  node.run_state[cookbook_name]['components'] ||= {}
  node.run_state[cookbook_name]['components']['alertmanager'] ||= {}
  node.run_state[cookbook_name]['components']['alertmanager']['templates'] =
    templates_list
end

# Write configuration for all components from attributes
node[cookbook_name]['components'].each_pair do |comp, config|
  next unless config['install?']

  configfile = "#{node[cookbook_name]['prefix_home']}/#{comp}/#{comp}.yml"
  config = h_to_a((config['config'] || {}).to_hash)
  override = node.run_state.dig(cookbook_name, 'components', comp) || {}
  config = config.merge(override, &merge_proc)

  file configfile do
    content config.to_yaml
    mode '0644'
    not_if { config.empty? }
  end
end

prometheus = node[cookbook_name]['components']['prometheus']
# Set-up prometheus rules directory
if prometheus['install?']
  prefix_dir = "#{node[cookbook_name]['prefix_home']}/prometheus"
  rules_dir = node[cookbook_name]['components']['prometheus']['rules_dir']
  directory "#{prefix_dir}/#{rules_dir}"

  prometheus['rules'].each do |file, rules|
    file "#{prefix_dir}/#{rules_dir}/#{file}" do
      mode '0644'
      content "#{rules.to_h.to_yaml}\n"
      notifies(
        :reload_or_try_restart, 'systemd_unit[prometheus.service]', :delayed
      )
    end
  end
end
