require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new(:test) do |t|
  ENV['RAILS_ENV'] = 'test'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb', 'test/**/*_spec.rb']
  t.verbose = true
end

Rake::TestTask.new(:test_with_rethinkdb) do |t|
  ENV['RAILS_ENV'] = 'test'
  ENV['TEST_WITH_RETHINKDB'] = 'true'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb', 'test/**/*_spec.rb']
  t.verbose = true
end
