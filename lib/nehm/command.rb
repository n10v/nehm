module Nehm

  ##
  # Base class for all Nehm commands. When creating a new nehm command, define
  # #initialize, #execute, #arguments, #description, #program_name, #summary
  # and #usage (as appropriate).
  # See the above mentioned methods for details.

  class Command

    ##
    # Hash with options of the command.

    attr_accessor :options

    ##
    # Invoke the command with the given list of arguments.

    def invoke(args)
      handle_options(args)
      execute
    end

    ##
    # Handle the given list of arguments by parsing them and recording the
    # results.

    def handle_options(args)
      parser = OptionParser.new(args, self)
      parser.parse
    end

    ##
    # Override to provide command handling.
    #
    # #options will be filled in with your parsed options, unparsed options will
    # be left in #options[:args].
    def execute
    end

    ##
    # Override to provide details of the arguments a command takes.  It should
    # return a left-justified string, one argument per line.
    #
    # For example:
    #
    #   def usage
    #     "nehm help COMMAND"
    #   end
    #
    #   def arguments
    #     "COMMAND          name of command to show help"
    #   end

    def arguments
    end

    ##
    # Override to display a longer description of what this command does.

    def description
    end

    ##
    # Override to display a short description of what this command does.

    def summary
    end

    ##
    # Override to display the usage for an individual nehm command.
    #
    # The text "[options]" is automatically appended to the usage text.

    def usage
    end

    ##
    # Add a command-line option
    #
    # Nehm don't use options with dashes to be more user-friendly

    def add_option(option, desc)
      @options ||= {}
      @options_descs ||= {}

      @options[option] = nil
      @options_descs[option] = desc
    end

    HELP = <<-EOF
#{'nehm'.green} is a console tool, which downloads, sets IDv3 tags and adds to your iTunes library your SoundCloud posts or likes in convenient way

#{'Avalaible nehm commands:'.yellow}
  #{'get'.green}        Download, set tags and add to your iTunes library last post or like from your profile
  #{'dl'.green}         Download and set tags last post or like from your profile
  #{'configure'.green}  Configure application
  #{'version'.green}    Show version of installed nehm

See #{'nehm help [command]'.yellow} to read about a specific subcommand
    EOF

  end
end
