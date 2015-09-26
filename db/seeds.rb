require 'parallel'

file_path = 'pings.json'

unless File.exists?(file_path)
  raise "Please copy `#{file_path}` to the root of the project"
end

file_content = File.read(file_path)
pings = JSON.parse(file_content)

# Disabling metrics preprocessing
Ping.auto_recalculate_metrics = false

# Processing the array in parallel processes = easy way to speed up the process
Parallel.each(pings, progress: 'Seeding Pings') do |ping|
  ping['ping_created_at'] = ping.delete('created_at')
  Ping.create(ping)
end

# Parallel creates PG connection issues
# https://github.com/grosser/parallel/issues/62
begin
  ActiveRecord::Base.connection.reconnect!
rescue
  ActiveRecord::Base.connection.reconnect!
end

# We recalculate preprocessed metrics for everything
Ping.registered_metrics.each &:refresh_all