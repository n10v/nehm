require 'nehm/tracks'

module Nehm
  class GetCommand < Command

    def initialize
      super

      add_option(:from, 'from PERMALINK',
                 'Get track(s) from user with PERMALINK')

      add_option(:to, 'to PATH',
                 'Download track(s) to PATH')

      add_option(:playlist, 'playlist PLAYLIST',
                 'Add track(s) to iTunes playlist with PLAYLIST name')
    end

    def execute
      Tracks[:get, @options]
    end

    def arguments
      { "#{'post'}"           => 'Get last post (track or repost) from your profile',
        "#{'<number> posts'}" => 'Get last <number> posts from your profile',
        "#{'like'}"           => 'Get your last like',
        "#{'<number> likes'}" => 'Get your last <number> likes',
        "#{'URL'}"            => 'Get track from entered URL' }
    end

    def program_name
      'nehm get'
    end

    def summary
      'Download tracks, set tags and add to your iTunes library tracks from Soundcloud'
    end

    def usage
      "#{program_name} ARGUMENT [OPTIONS]"
    end

  end
end
