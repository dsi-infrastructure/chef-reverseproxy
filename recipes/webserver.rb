#
# Cookbook Name:: chef-reverseproxy
# Recipe:: webserver
#
# Copyright (C) 2014 Stephane LII
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe 'apache2'
include_recipe 'apache2::mod_proxy_http'

dbgi =  Chef::DataBagItem.load('reverseproxies', node['fqdn'].tr('.', '_'))

sites_enabled = dbgi['members']
sites_enabled = sites_enabled.tr(' ', '').split(',')

sites_enabled.each do |cle|
  # Set up the Apache virtual host reverse proxy
  web_app dbgi[cle]['server_name'] do
    server_name dbgi[cle]['server_name']
    server_name_proxy dbgi[cle]['server_name_proxy']

    template 'test.gov.pf.conf.erb'
    log_dir node['apache']['log_dir']
  end

  hostsfile_entry dbgi[cle]['server_ip_proxy'] do
    hostname dbgi[cle]['server_name_proxy']
    action :create_if_missing
  end
end
