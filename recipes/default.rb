#
# Cookbook Name:: kafka-manager
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

kafka_manager 'default' do
  package_version "#{node['kafka-manager']['version']}"
  download_url "#{node['kafka-manager']['download_url']}"
  action :install
end

template '/usr/share/kafka-manager/conf/application.conf' do
  source 'application.conf.erb'
  variables ({
    :zkhosts => "#{node['kafka-manager']['zkhosts']}"
  })
  notifies :restart, 'service[kafka-manager]'
end

if (node['platform'] == 'ubuntu' && node['platform_version'].to_f > 16.0) || (node['platform'] == 'debian' && node['platform_version'].to_f > 9.0)
   template "systemd-service" do
     path "/etc/systemd/system/kafka-manager.service"
     source "systemd-service.erb"
     owner "root"
     group "root"
     mode "0644"
     variables(
         :service_name => 'kafka-manager',
         :jar_path => '/usr/share/kafka-manager/bin/kafka-manager',
         :service_user => 'kafka-manager',
         :service_group => 'kafka-manager'
     )
   end
 end

execute "systemctl daemon-reload" do
  command "systemctl daemon-reload"
  action :nothing
  subscribes :run, 'remote_file[download_jar]', :immediately
  only_if { (node['platform'] == 'ubuntu' && node['platform_version'].to_f > 16.0) || (node['platform'] == 'debian' && node['platform_version'].to_f > 9.0) }
end

execute "systemctl enable service" do
  command "systemctl enable kafka-manager.service"
  action :run
  only_if { (node['platform'] == 'ubuntu' && node['platform_version'].to_f > 16.0) || (node['platform'] == 'debian' && node['platform_version'].to_f > 9.0) }
end
 
service 'kafka-manager' do
  action [ :enable, :start ]
end
