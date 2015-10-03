module Nehm
  # ArgumentParser process arguments and return hash with options
  # Name of the method corresponds to the name of the command
  class ArgumentParser
    def initialize(args, command)
      @args = args
      @command = command
    end

    def parse
      parse_subcommands
      parse_post_value_options
      parse_pre_value_options
    end

    def parse_pre_value_options
      @command.pre_value_options.each do |option|
        if @args.include? option
          index = @args.index(option)
          value = @args[index - 1]
          @args.delete_at(index)
          @args.delete_at(index - 1)

          @command.options[option] = value
        end
      end
    end

    def parse_post_value_options
      @command.post_value_options.each do |option|
        if @args.include? option
          index = @args.index(option)
          value = @args[index + 1]
          @args.delete_at(index + 1)
          @args.delete_at(index)

          @command.options[option] = value
        end
      end
    end

    def parse_subcommands
      @command.subcommands.each do |option|
        if @args.include? option
          index = @args.index(option)
          @args.delete_at(index)

          @command.options[option] = true
        end
      end
    end
  end
end
