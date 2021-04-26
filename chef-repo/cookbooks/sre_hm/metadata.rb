name 'sre_hm'
maintainer 'Simonas Valkiūnas'
maintainer_email 'simonas.valkiunas@gmail.com'
license 'MIT'
description 'SRE Homework task'
version '1.0.0'
chef_version '>= 14'

supports 'centos'
supports 'redhat'

depends 'prometheus_exporters', '~> 0.17.2'
depends 'grafana', '~> 8.8.0'
depends 'prometheus-platform', '~> 2.2.0'
