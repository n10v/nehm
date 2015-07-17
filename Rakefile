task default: %w(build install delete)

task :build do
  system('gem build nehm.gemspec')
end

task :install do
  system('gem install ./nehm-1.0.gem')
end

task :delete do
  File.delete('./nehm-1.0.gem')
end
