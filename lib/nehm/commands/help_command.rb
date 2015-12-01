module Nehm
  class HelpCommand < Command

    SPACES_BTWN_NAME_AND_DESC = 15

    def execute
      command_name = options[:args].pop
      if command_name.nil?
        UI.say HELP
        UI.term
      end

      @cmd = CommandManager.find_command(command_name)

      show_usage
      show_summary
      show_arguments unless @cmd.arguments.empty?
      show_options unless @cmd.options.empty?
    end

    def arguments
      { 'COMMAND' => 'name of command (can be abbreviated) to show help' }
    end

    def program_name
      'nehm help'
    end

    def summary
      'Show help for specified command'
    end

    def usage
      "#{program_name} COMMAND"
    end

    private

    def find_longest_name(names)
      names.inject do |longest, word|
        word.length > longest.length ? word : longest
      end
    end

    def show_usage
      UI.say "#{'Usage:'.yellow} #{@cmd.usage}"
    end

    def show_summary
      UI.newline
      UI.say "#{'Summary:'.yellow}"
      UI.say "  #{@cmd.summary}"
    end

    def show_arguments
      UI.newline
      UI.say "#{'Arguments:'.yellow}"
      show_info(@cmd.arguments)
    end

    def show_options
      UI.newline
      UI.say "#{'Options:'.yellow}"
      show_info(@cmd.options_descs)
    end

    def show_info(hash)
      @longest ||=
        Proc.new do
          names = []
          names += @cmd.arguments.keys unless @cmd.arguments.empty?
          names += @cmd.options_descs.keys unless @cmd.options_descs.empty?
          find_longest_name(names).length
        end.call

      hash.each do |name, desc|
        space_count = @longest + SPACES_BTWN_NAME_AND_DESC
        UI.say "  #{name.green.ljust(space_count)}#{desc}"
      end
    end

  end
end
