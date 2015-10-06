module Nehm

  ##
  # OptionParser parses options and add hash with options to specified command

  class OptionParser

    def initialize(args, command)
      @args = args
      @command = command
    end

    def parse
      options = @command.options.keys.map(&:to_s)
      options.each do |option|
        if @args.include? option
          index = @args.index(option)
          value = @args[index + 1]
          @args.delete_at(index + 1)
          @args.delete_at(index)

          @command.options[option] = value
        end
      end
      @command.options[:args] = @args
    end

  end
end
