require 'nehm/tracks'

module Nehm
  class DlCommand < Command

    def initialize
      super

      add_option(:from, 'from PERMALINK'.green,
                 'Get track(s) from user with PERMALINK')

      add_option(:to, 'to PATH'.green,
                 'Download track(s) to PATH')
    end

    def execute
      Tracks[:dl, @options]
    end

    def arguments
      { "#{'post'.green}"           => 'Download last post (track or repost) from your profile',
        "#{'<number> posts'.green}" => 'Download last <number> posts from your profile',
        "#{'like'.green}"           => 'Download your last like',
        "#{'<number> likes'.green}" => 'Download your last <number> likes',
        "#{'url'.magenta}"          => 'Download track from entered url' }
    end

    def program_name
      'nehm dl'
    end

    def summary
      'Download and set tags any track from Soundcloud'
    end

    def usage
      "#{program_name} ARGUMENT [OPTIONS]"
    end

  end
end
