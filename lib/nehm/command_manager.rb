require 'nehm/command'

module Nehm

  ##
  # The command manager contains information about all nehm commands, find
  # and run them

  module CommandManager

    COMMANDS = [
      :configure,
      :dl,
      :get,
      :help,
      :version
    ]

    ##
    # Run the command specified by 'args'.

    def self.run(args)
      if args.empty?
        UI.say Nehm::Command::HELP
        UI.term
      end

      cmd_name = args.shift.downcase
      cmd = find_command(cmd_name)
      cmd.invoke(args)
    end

    def self.find_command(cmd_name)
      possibilities = find_command_possibilities(cmd_name)

      if possibilities.size > 1
        UI.term "Ambiguous command #{cmd_name} matches [#{possibilities.join(', ')}]"
      elsif possibilities.empty?
        UI.term "Unknown command #{cmd_name}"
      end

      command_instance(possibilities.first)
    end

    module_function

    def find_command_possibilities(cmd_name)
      len = cmd_name.length
      COMMANDS.select { |command| command[0, len] == cmd_name }
    end

    def command_instance(command_name)
      command_name = command_name.to_s
      const_name = command_name.capitalize << 'Command'

      require_commands
      Nehm.const_get(const_name).new
    end

    def require_commands
      project_root = File.dirname(File.absolute_path(__FILE__))
      Dir.glob(project_root + '/commands/*') { |file| require file }
    end

  end
end
