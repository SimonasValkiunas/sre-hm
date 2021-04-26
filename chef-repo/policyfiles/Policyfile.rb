name "Policyfile"

default_source :supermarket, "https://supermarket.chef.io" do |s|
    s.preferred_for [ "prometheus_exporters", "prometheus-platform" ]
  end

cookbook 'prometheus_exporters', '~> 0.17.2', :supermarket
cookbook 'prometheus-platform', '~> 2.2.0', :supermarket
cookbook 'grafana', '~> 8.8.0', :supermarket
cookbook "sre_hm", path: "./../cookbooks/sre_hm"

run_list "sre_hm"

