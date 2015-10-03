require 'colored'

module Nehm::UI
  def self.error(expression)
    abort expression.red
  end

  def self.say(expression)
    puts expression
  end

  def self.terminate_interaction
    exit
  end

  def self.warning
    puts expression.yellow
  end
end
