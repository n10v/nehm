module Nehm
  class Command
    attr_accessor :options

    attr_reader :post_value_options

    attr_reader :pre_value_options

    attr_reader :subcommands

    def execute
    end

    def invoke(args)
      handle_options(args)
      execute
    end

    def add_subcommand(subcommand, desc)
      @subcommands ||= []
      @subcommands_descs ||= {}

      @subcommands << subcommand
      @subcommands_descs[subcommand] = desc
    end

    def add_post_value_option(option, desc)
      @post_value_options ||= []
      @options_descs ||= {}

      @post_value_options << option
      @options_descs[option] = desc
    end

    def add_pre_value_option(option, desc)
      @pre_value_options ||= []
      @options_descs ||= {}

      @pre_value_options << option
      @options_descs[option] = desc
    end

    private

    def handle_options(args)
      parser = ArgumentParser.new(args, self)
      parser.parse
    end
  end
end
