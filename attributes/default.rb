default['kafka-manager']['version'] = '1.2.7' #1.2.8 and newer don't scale well with large clusters https://github.com/yahoo/kafka-manager/issues/162
default['kafka-manager']['zkhosts'] = 'kafka-manager-zookeeper:2181' #comma separated, no spaces
default['kafka-manager']['download_url'] = 'https://packagecloud.io/spuder/kafka-manager/packages/ubuntu/#{node[\'lsb\'][\'codename\']}/kafka-manager_#{node[\'kafka-manager\'][\'version\']}_all.deb/download.deb'
default['kafka-manager']['java_opts'] = ''
