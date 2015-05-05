# Split old cron to crond (deamon) and cron (cronjobs for Scalr app)
# We need to make sure to clean up old "cron" files and service
file "#{log_dir_for(node, 'cron')}/crond.log" do
  action      :delete
end

directory log_dir_for(node, 'cron') do
  action           :delete
  ignore_failure   true
end

(disabled_crons(node) | enabled_crons(node)).each do |cron|

  file "#{bin_dir_for node, 'cron'}/#{cron[:name]}" do
    action :delete
  end

  file "#{etc_dir_for node, 'cron'}/cron.d/#{cron[:name]}" do
    action :delete
  end
end

directory "#{etc_dir_for(node, 'cron')}/cron.d" do
  action           :delete
  ignore_failure   true
end

directory etc_dir_for(node, 'cron') do
  action           :delete
  ignore_failure   true
end

directory bin_dir_for(node, 'cron') do
  action           :delete
  ignore_failure   true
end

# Stop old cron service if running
supervisor_service 'cron' do
  action service_is_up?(node, 'cron') ? [:stop, :disable] : [:disable]
end
