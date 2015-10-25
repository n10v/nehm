require 'nehm/menu'

module Nehm
  module UI

    def self.ask(arg)
      say arg
      gets.chomp
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
