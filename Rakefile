require 'rake'
require 'rake/testtask'
require 'rdoc/task'

desc 'Default: run the proxy tests'
task :default => :test

namespace :test do
  desc 'Default: run the proxy tests for all versions of actionpack'
  task :all do
    versions = `gem list`.match(/actionpack \((.+)\)/).captures[0].split(/, /).select { |v| v[0,1].to_i > 1 }
    versions.each do |version|
      puts "\n\n============================================================="
      puts "TESTING WITH ACTION PACK VERSION #{version}\n\n"
      system "rake test ACTION_PACK_VERSION=#{version}"
    end
  end
end

desc 'Test the proxy plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the proxy plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Proxy'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.markdown')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
