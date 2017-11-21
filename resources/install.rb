resource_name :kafka_manager
property :repo, String, default: 'spuder/kafka-manager'
property :package_version, String, default: '1.2.7' #1.2.8 and newer don't scale well with large clusters https://github.com/yahoo/kafka-manager/issues/162

action :install do

  # Create a service user since the .deb file requires it
  user 'kafka-manager' do
    comment 'kafka-manager'
    shell '/bin/false'
    action :create
  end

  case node['platform_family']
#  when 'rhel'
#    repo_type = 'rpm'
  when 'debian'
    repo_type = 'deb'
  else
    Chef::Log.fatal("Only supports ubuntu / debian. Found: #{node['platform_family']}")
  end

#  packagecloud_repo "#{repo}" do
#    type "#{repo_type}"
#    action :add
#  end

  remote_file "kafka-manager_#{package_version}_all.deb" do
    source "https://packagecloud.io/spuder/kafka-manager/packages/ubuntu/trusty/kafka-manager_#{package_version}_all.deb/download.deb"
    owner user
    group user
    mode '0755'
  end
  
  package 'kafka-manager' do
    source "kafka-manager_#{package_version}_all.deb"
#    version "#{package_version}"
    action :install
  end

  cookbook_file '/usr/share/kafka-manager/conf/application.ini' do
    source 'conf/application.ini'
    owner 'root'
    group 'root'
    mode 00644
    action :create
  end

  # chown the kafka-manager folder so the kafka-manager can use it
  execute 'chown kafka-manager' do
    command 'chown -R kafka-manager:kafka-manager /usr/share/kafka-manager'
    user "root"
    action :run
    not_if "stat -c %U /usr/share/kafka-manager/README.md | grep kafka-manager"
  end

  # chown the kafka-manager log directory since package chowns to root
  execute 'chown kafka-manager log directory' do
    command 'chown -R kafka-manager:kafka-manager /var/log/kafka-manager'
    user "root"
    action :run
    not_if "stat -c %U /var/log/kafka-manager | grep kafka-manager"
  end

end
