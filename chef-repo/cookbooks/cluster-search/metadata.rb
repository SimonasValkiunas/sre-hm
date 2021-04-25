# frozen_string_literal: true

name 'cluster-search'
maintainer 'Chef Platform'
maintainer_email(
  'incoming+chef-platform-cluster-search-2784994-issue-@incoming.gitlab.com'
)
license 'Apache-2.0'
description 'Library to help searching cluster nodes in Chef cookbooks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
source_url 'https://gitlab.com/chef-platform/cluster-search'
issues_url 'https://gitlab.com/chef-platform/cluster-search/issues'
version '1.6.0'

chef_version '>= 12.14'

supports 'centos', '>= 7.1'
