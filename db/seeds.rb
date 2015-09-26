require 'parallel'

file_path = 'pings.json'

unless File.exists?(file_path)
  raise "Please copy `#{file_path}` to the root of the project"
end

file_content = File.read(file_path)
pings = JSON.parse(file_content)

# Processing the array in parallel processes = easy way to speed up the process
Parallel.each(pings, progress: 'Seeding Pings') do |ping|
  ping['ping_created_at'] = ping.delete('created_at')
  Ping.create(ping)
end

# require 'factory_girl_rails'
# Parallel.each(0..100_000, in_processes: 5, progress: 'Seeding') do |n|
#   FactoryGirl.create_list(:ping, 10, origin: 'millionpointscity')
# end