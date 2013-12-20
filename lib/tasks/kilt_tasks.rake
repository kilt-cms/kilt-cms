desc 'Show all the calls available in Kilt based on the current config'
task :kilt => :environment do
  
  puts Kilt::Utils.tips
  
end