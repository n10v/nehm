module Nehm

  ##
  # OptionParser parses options and add hash with options to specified command

  class OptionParser

    def initialize(args, command)
      @args = args
      @command = command
      @option_names = command.options.keys
    end

    def parse
      @option_names.each do |option|
        if @args.include? option
          index = @args.index(option)
          value = @args[index + 1]
          @args.delete_at(index + 1)
          @args.delete_at(index)

          @command.options[option] = value
        end
      end

      @command.option[:args] = @args
    end

  end
end
