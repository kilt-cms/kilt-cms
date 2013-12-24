require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  ENV['RAILS_ENV'] = 'test'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb', 'test/**/*_spec.rb']
  t.verbose = true
end
