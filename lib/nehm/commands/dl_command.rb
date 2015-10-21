require 'nehm/tracks'

module Nehm
  class DlCommand < Command

    def initialize
      super

      add_option(:from, 'from PERMALINK',
                 'Get track(s) from user with PERMALINK')

      add_option(:to, 'to PATH',
                 'Download track(s) to PATH')
    end

    def execute
      Tracks[:dl, @options]
    end

    def arguments
      { "#{'post'}"           => 'Download last post (track or repost) from your profile',
        "#{'<number> posts'}" => 'Download last <number> posts from your profile',
        "#{'like'}"           => 'Download your last like',
        "#{'<number> likes'}" => 'Download your last <number> likes',
        "#{'URL'}"            => 'Download track from entered URL' }
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
