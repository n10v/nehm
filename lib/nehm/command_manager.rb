require 'nehm/command'

module Nehm

  ##
  # The command manager contains information about all nehm commands
  # It also find and run them

  module CommandManager

    COMMANDS = [
      :configure,
      :dl,
      :get,
      :help,
      :search,
      :select,
      :version
    ]

    ##
    # Run the command specified by 'args'

    def self.run(args)
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

    def self.find_command_possibilities(cmd_name)
      len = cmd_name.length
      COMMANDS.select { |command| command[0, len] == cmd_name }
    end

    def self.command_instance(command_name)
      command_name = command_name.to_s
      const_name = command_name.capitalize << 'Command'

      require "nehm/commands/#{command_name}_command"
      Nehm.const_get(const_name).new
    end

  end
end
