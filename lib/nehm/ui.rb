require 'highline'

require 'nehm/page_view'

module Nehm
  module UI

    def self.ask(arg, &block)
      HighLine.new.ask(arg, &block)
    end

    def self.error(msg)
      puts "#{msg}\n".red
    end

    def self.menu(&block)
      HighLine.new.choose(&block)
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

    def self.page_view(&block)
      PageView.new.start(&block)
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
