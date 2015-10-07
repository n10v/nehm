require 'nehm/version'

module Nehm
  class VersionCommand < Command

    def execute
      UI.say VERSION
    end

    def program_name
      'nehm version'
    end

    def summary
      "Show nehm's verion"
    end

    def usage
      program_name
    end

  end
end
