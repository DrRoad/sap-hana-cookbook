# Cookbook Name:: hana
# Recipe:: install
# Installs SAP Hana on the node.

# check if there is a shared volume defined - if yes, we are on a master and run it, if no continue
if "#{node['hana']['dist']['sharedvolume']}" != ""
  Chef::Log.info "a shared volume #{node['hana']['dist']['sharedvolume']} is defined and will be mounted"
  include_recipe "hana::mount-shared-volume"
end

# check if any hana installation was done already
if !File.exists?("#{node['hana']['installpath']}/#{node['hana']['sid']}/install.finished")

  hana_install_command = "./hdbinst --batch --sid=#{node['hana']['sid']} --number=#{node['hana']['instance']} --password=#{node['hana']['password']} --system_user_password=#{node['hana']['syspassword']} --autostart=#{node['hana']['autostart']} --shell=/bin/sh --userid=#{node['hana']['userid']} --import_content=#{node['hana']['import_content']} --sapmnt=#{node['hana']['installpath']}"

  server "run install hana node" do
    exe "#{hana_install_command}"
  end

  # write a file, to the fs, which will state that the installation is finished, so if any worker installation runs, it can be sure
  # that the installation of the master was finished
  file "Create installation completion flag" do
    path "#{node['hana']['installpath']}/#{node['hana']['sid']}/install.finished"
    action :create
  end

else
  log "It looks like there is already hana installed on this node, so skipping this step"
end
