require_relative 'lib/nehm/version.rb'
task default: %w(build install delete)

file = 'nehm-' + Nehm::VERSION + '.gem'

task :build do
  system('gem build nehm.gemspec')
end

task :install do
  system('gem install ./' + file)
end

task :delete do
  File.delete('./' + file)
end

task :push => :build do
  system('gem push ' + file)
  File.delete('./' + file)
end
