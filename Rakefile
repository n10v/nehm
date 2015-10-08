require_relative 'lib/nehm/version.rb'
task default: %w(build install delete)

file = 'nehm-' + Nehm::VERSION + '.gem'

##
# Build gem with project's gemspec

task :build do
  system('gem build nehm.gemspec')
end

##
# Install gem from project root directory

task :install do
  system('gem install ./' + file)
end

##
# Delete gem file

task :delete do
  File.delete('./' + file)
end

##
# Push to rubygems

task :push => :build do
  `gem push #{file}`
  File.delete('./' + file)
end

##
# Add command with boilerplate code
#
# For example, you want to add 'get' command
# For that you should input 'rake cmd[get]'

task :cmd, [:cmd] do |_, args|
  cmd = args[:cmd]
  cmd_file = "lib/nehm/commands/#{cmd}_command.rb"

  puts "Making #{cmd} command..."

  code = <<-EOF
module Nehm

  ##
  # Write here description for command

  class #{cmd.capitalize}Command

    ##
    # Add all command's options in 'initialize' method

    def initialize
    end

    def execute
    end

    def arguments
    end

    def program_name
      'nehm #{cmd}'
    end

    def summary
    end

    def usage
    end

  end
end
  EOF

  # Write to file
  File.open(cmd_file, 'w') { |f| f.write(code) }

  puts "Successfully made #{cmd} command!"
  puts "Don't forget to add the name of command to CommandManager::COMMANDS"
end
