require 'nehm/option_parser'

module Nehm

  ##
  # Base class for all Nehm commands. When creating a new nehm command, define
  # #initialize, #execute, #arguments, #program_name, #summary and #usage
  # (as appropriate)
  # See the above mentioned methods for details

  class Command

    ##
    # Hash with options of the command

    attr_accessor :options

    ##
    # Hash with descriptions of each option

    attr_accessor :options_descs

    ##
    # In 'initialize' should be defined all options by method 'add_option'
    # See get_command.rb as example

    def initialize
      @options = {}
      @options_descs = {}
    end

    ##
    # Invoke the command with the given list of arguments

    def invoke(args)
      handle_options(args)
      execute
    end

    ##
    # Handle the given list of arguments by parsing them and recording the
    # results

    def handle_options(args)
      parser = OptionParser.new(args, self)
      parser.parse
    end

    ##
    # Override to provide command handling
    #
    # #options will be filled in with your parsed options, unparsed options will
    # be left in #options[:args]

    def execute
      raise StandardError, 'generic command has no actions'
    end

    ##
    # Override to provide details of the arguments a command takes
    #
    # For example:
    #
    #   def usage
    #     "#{program_name} COMMAND"
    #   end
    #
    #   def arguments
    #     ['COMMAND', 'name of command to show help']
    #   end

    def arguments
      {}
    end

    ##
    # The name of the command for command-line invocation

    def program_name
    end

    ##
    # Override to display a short description of what this command does

    def summary
    end

    ##
    # Override to display the usage for an individual nehm command
    #
    # The text "[options]" is automatically appended to the usage text

    def usage
    end

    ##
    # Add a command-line option
    #
    # Nehm don't use options with dashes to be more user-friendly
    #
    # See 'get_command.rb' as example

    def add_option(option, usage, desc)
      @options[option] = nil
      @options_descs[usage] = desc
    end

  end
end
