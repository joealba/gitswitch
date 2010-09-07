require 'rubygems'
require 'rake'
# require 'rspec/core'
# require 'rspec/core/rake_task'


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "gitswitch"
    gem.summary = %Q{Easy git user switching}
    gem.description = %Q{Easily switch your git name/e-mail user info -- Handy for work vs. personal and for pair programming}
    gem.email = "joe@joealba.com"
    gem.homepage = "http://github.com/joealba/gitswitch"
    gem.authors = ["Joe Alba"]
#    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
#    gem.add_development_dependency "rspec", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "gitswitch #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


# desc 'Default: Run specs'
# task :default => :spec
# 
# desc 'Run specs'
# RSpec::Core::RakeTask.new(:spec) do |t|
#   t.pattern = FileList["spec/**/*_spec.rb"]
# end


