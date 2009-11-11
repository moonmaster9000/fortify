require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = "fortify"
    gemspec.summary     = "Default attributes for your ActiveResource objects"
    gemspec.description = "Know how you can't just use 'form_for' in rails with a newly initialized ActiveResource object? " +
                          "Ever get annoyed at having to add default attributes to your newly initialized ActiveResource objects? " + 
                          "Fortify gives you the power to DRY'ly define default attributes for your ActiveResource derived classes."
    gemspec.email       = "moonmaster9000@gmail.com"
    gemspec.files       = FileList['lib/**/*.rb', 'README.rdoc']
    gemspec.homepage    = "http://github.com/moonmaster9000/fortify"
    gemspec.authors     = ["Matt Parker"]
    gemspec.add_dependency('rails', '>= 2.3.3')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
