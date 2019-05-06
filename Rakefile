require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

desc 'Run rubocop'
RuboCop::RakeTask.new do |task|
  task.options       = %w[--display-cop-names]
  task.formatters    = %w[fuubar]
  task.fail_on_error = true
end

task spec: :test
task default: :test
