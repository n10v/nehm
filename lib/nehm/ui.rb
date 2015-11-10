require 'nehm/menu'

module Nehm
  module UI

    ##
    # This constant used to set delay between user operation
    # Because it's more comfortable to have a small delay
    # between interactions

    SLEEP_PERIOD = 0.6

    def self.ask(arg)
      say arg
      $stdin.gets.chomp
    end

    def self.error(msg)
      puts "#{msg}\n".red
    end

    def self.newline
      puts
    end

    def self.say(msg)
      puts msg
    end

    def self.success(msg)
      puts msg.green
    end

    def self.menu(&block)
      Menu.new(&block)
    end

    def self.term(msg = nil)
      if msg
        abort msg.red
      else
        exit
      end
    end

    def self.warning(msg)
      puts "#{msg}".yellow
    end

  end
end
