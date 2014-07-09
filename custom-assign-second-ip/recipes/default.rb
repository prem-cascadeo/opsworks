include_recipe "custom-aws-cli-creds::default"

require "json"
require "open-uri"

Chef::Resource::RubyBlock.send(:include, HelperFunctions)

ENV['AWS_CONFIG_FILE'] = ::File.join(node['custom-aws-cli-creds']['config-dir'], "aws_cli_config")

ruby_block "verify_secondary_IP" do
  block do
    raise "Cannot find secondary IP!" unless secondary_ip_exists()
    Chef::Log.info("Secondary IP #{@secondary_private_ip} was assigned.")
  end
  action :nothing
end

service "network" do
  service_name "network"
  action :nothing
end

ruby_block "assign_secondary_IP" do
  not_if { secondary_ip_exists() }
  block do
    assign_secondary_ip()
  end
  notifies :restart, "service[network]", :immediately
  notifies :create, "ruby_block[verify_secondary_IP]", :immediately
end

