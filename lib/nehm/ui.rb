require 'colored'

module Nehm::UI
  def self.error(message)
    abort "#{message}\n".red
  end

  def self.newline
    puts "\n"
  end

  def self.say(message)
    puts message
  end

  def self.success(message)
    puts message.green
  end

  def self.term(message)
    if message
      abort message.red
    else
      exit
    end
  end

  def self.warning
    puts "#{message}\n".yellow
  end
end
