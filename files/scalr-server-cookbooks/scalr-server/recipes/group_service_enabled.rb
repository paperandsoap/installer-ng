# service directories
directory bin_dir_for(node, 'service') do
  owner     'root'
  group     'root'
  mode      0755
  recursive true
end

cookbook_file "#{bin_dir_for node, 'service'}/scalrpy_proxy" do
  owner     'root'
  group     'root'
  source 'scalrpy_proxy'
  mode    0755
end

directory run_dir_for(node, 'service') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end

directory log_dir_for(node, 'service') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end

directory "#{data_dir_for(node, 'service')}/graphics" do
  # This is wher we serve stats graphics from
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end


# Actually launch the services

enabled_services(node).each do |svc|
  # Make sure we're only dealing with symbols here (recursively)
  HashHelper.symbolize_keys_deep!(svc)

  # TODO - delete service for services that are disabled
  supervisor_service "service-#{svc[:service_name]}" do
    command         "#{bin_dir_for node, 'service'}/scalrpy_proxy" \
                    " #{run_dir_for node, 'service'}/#{svc[:service_name]}.pid" \
                    " #{node[:scalr_server][:install_root]}/embedded/bin/python" \
                    " #{scalr_bundle_path node}/app/python/scalrpy/#{svc[:service_module]}.py" \
                    " --pid-file=#{run_dir_for node, 'service'}/#{svc[:service_name]}.pid" \
                    " --log-file=#{log_dir_for node, 'service'}/#{svc[:service_name]}.log" \
                    " --user=#{node[:scalr_server][:app][:user]}" \
                    " --group=#{node[:scalr_server][:app][:user]}" \
                    " --config=#{scalr_bundle_path node}/app/etc/config.yml" \
                    ' --verbosity=INFO' \
                    " #{svc[:service_extra_args]}" \
                    # Note: 'start' is added by the proxy.
    stdout_logfile  "#{log_dir_for node, 'supervisor'}/service-#{svc[:service_name]}.log"
    stderr_logfile  "#{log_dir_for node, 'supervisor'}/service-#{svc[:service_name]}.err"
    action          [:enable, :start]
    autostart       true
    # TODO - None of those subscriptions should run if the service isn't already running
    # TODO - Use a stop command proxy.
    subscribes      :restart, 'template[scalr_config]', :delayed
    subscribes      :restart, 'file[scalr_cryptokey]', :delayed
    subscribes      :restart, 'file[scalr_id]', :delayed
  end
end