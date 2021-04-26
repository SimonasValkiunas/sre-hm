name "Policyfile"

default_source :supermarket, "https://supermarket.chef.io" do |s|
    s.preferred_for [ "prometheus_exporters", "prometheus-platform" ]
  end

cookbook 'prometheus_exporters', '~> 0.17.2', path: "~/sre-hm/chef-repo/cookbooks/prometheus_exporters"
cookbook 'prometheus-platform', '~> 2.2.0', path: "~/sre-hm/chef-repo/cookbooks/prometheus-platform"
cookbook 'grafana', '>= 8.8.0', path: "~/sre-hm/chef-repo/cookbooks/grafana"
cookbook "sre_hm", path: "~/sre-hm/chef-repo/cookbooks/sre_hm"

run_list "sre_hm"

