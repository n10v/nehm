require 'nehm/menu'

module Nehm
  module UI

    ##
    # This constant used to set delay between user operation
    # Because it's more comfortable to have a small delay
    # between interactions

    SLEEP_PERIOD = 0.7

    def self.ask(arg = "")
      say arg
      $stdin.gets.chomp
    end

    def self.error(msg)
      say "#{msg}\n".red
    end

    def self.menu(&block)
      Menu.new(&block)
    end

    def self.newline
      say
    end

    def self.say(msg = '')
      puts msg
    end

    def self.sleep
      Kernel.sleep(SLEEP_PERIOD)
    end

    def self.success(msg)
      say msg.green
    end

    def self.term(msg = nil)
      say msg.red if msg
      raise NehmExit
    end

    def self.warning(msg)
      say "#{msg}".yellow
    end

  end
end
