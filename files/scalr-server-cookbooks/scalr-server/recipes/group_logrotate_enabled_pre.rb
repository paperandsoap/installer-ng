etc = "#{node[:scalr_server][:install_root]}/etc"

directory "#{etc}/logrotate" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# logrotate config file
log = "#{node[:scalr_server][:install_root]}/var/log/scalr"
config = "#{etc}/logrotate/config"

template config do
  source 'logrotate/config.erb'
  variables :path => log
  mode 0755
end

# cronjob for logrotate
cmd = "#{node[:scalr_server][:install_root]}/embedded/sbin/logrotate"
cron_file = "#{etc}/cron/cron.d/logrotate"

template cron_file do
  source 'logrotate/cron.erb'
  variables :cmd => cmd, :conf => config 
  mode 0755
  notifies  :restart, 'supervisor_service[crond]' if service_is_up?(node, 'crond')
end
