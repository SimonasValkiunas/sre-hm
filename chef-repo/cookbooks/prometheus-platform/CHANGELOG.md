Changelog
=========

2.2.0
-----

Main:

- fix: use correct config variable for checksum
- feat: update all components to latest version
  + prometheus to 2.17.2
  + alertmanager to 0.20.0
  + blackbox_exporter to 0.16.0
  + consul_exporter to 0.6.0
  + graphite_exporter to 0.7.0
  + memcached_exporter to 0.6.0
  + mysqld_exporter to 0.12.1
  + node_exporter to 0.18.1
  + pushgateway to 1.2.0
  + statsd_exporter to 0.15.0

Tests:

- fix pushgateway journalctl expected output
- fix statsd journalctl expected output
- add rspec-core to Gemfile
- accept chef license
- make kitchen.yml config file visible
- switch to chefplatform image

Misc:

- chore: add time to storage.tsdb.retention option
- chore: set 2020 in copyright notice
- style(rubocop): fix multiple offenses
  + add FrozenStringLiteralComment
  + use `e` instead of `error`
  + do not use send method mith mix-in

2.1.0
-----

Main:

- feat: add alertmanager template generation
- feat: update all components to latest version

Misc:

- chore: set generic maintainer & helpdesk email
- chore: add supermarket category in .category
- style: fix rubocop offenses (add line after guard)
- fix: replace match? by match for ruby 2.3 compat
- doc: use doc in git message instead of docs

2.0.0
-----

Main:

- feat: breaking change migration to support Prometheus 2.X (actually 2.2.1)
  + update all components to latest version
  + set all flags with double dash
  + put alertmanager discovery in config
  + update storage flags
  + reformat rules in yaml
  + adapt tests to new logs

Tests:

- fix waiting condition on targets
- include .gitlab-ci.yml from test-cookbook
- replace deprecated require\_chef\_omnibus

Misc:

- feat: set default data retention to 15d
- chore: add 2018 to copyright notice

1.1.0
-----

Main:

- add default config for scrapers
- change default data directories to /var/opt
- update default version of components:
  + prometheus to 1.7.2
  + blackbox to 0.9.1
  + alertmanager to 0.9.1

Tests:

- fix rubocop on heredoc delimiters

1.0.0
-----

Initial version:

- with Centos support
- manage all artifacts available on https://prometheus.io/download/
