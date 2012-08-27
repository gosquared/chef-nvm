#
# Cookbook Name:: nvm
# Recipe:: default
#
# Copyright 2012, action.io
#
# All rights reserved - Do Not Redistribute
#

package 'git-core'

bash "Install NVM" do
  @user  = node['nvm']['user']
  @group = node['nvm']['group'] || @user
  @home  = node['nvm']['home'] || "/home/#{@user}"

  user  @user
  group @group
  cwd   @home

  code <<-EOF
if [ ! -d #{@home}/.nvm ]
  then
    git clone git://github.com/creationix/nvm.git #{@home}/.nvm
fi

grep nvm.sh #{@home}/.bashrc

if [ $? -eq 1 ]
  then
    echo -e '\n\n. ~/.nvm/nvm.sh' >> #{@home}/.bashrc
    . ~/.nvm/nvm.sh
fi
  EOF

  notifies :run, "execute[install-nodes]", :immediately
  not_if "test -d #{@home}/.nvm"
end

execute "install-nodes" do
  @all_node_versions = Array(node['nvm']['node_versions'])

  @all_node_versions.each do |node_version|
    command <<-EOF
nvm install #{node_version}
nvm use #{node_version}
    EOF
  end

  if node['nvm']['default_node_version'] || @all_node_versions.count > 0
    notifies :run, "execute[make-default-node-version]", :immediately
  end

  action :nothing
end

execute "make-default-node-version" do
  @default_node_version = node['nvm']['default_node_version'] || Array(node['nvm']['node_versions']).first
  command "nvm default use #{@default_node_version}" 

  action :nothing
end
