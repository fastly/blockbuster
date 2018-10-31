require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'spec'
  t.libs << 'lib'
  t.test_files = FileList['spec/**/*_spec.rb']
end

desc 'Run rubocop'
RuboCop::RakeTask.new do |task|
  task.options       = %w[--display-cop-names]
  task.formatters    = %w[fuubar]
  task.fail_on_error = true
end

task spec: :test
task default: :test
