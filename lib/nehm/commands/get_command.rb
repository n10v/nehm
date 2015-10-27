module Nehm
  class GetCommand < Command

    def initialize
      super

      add_option(:from, 'from PERMALINK',
                 'Get track(s) from user with PERMALINK')

      add_option(:to, 'to PATH',
                 'Download track(s) to PATH')

      add_option(:pl, 'pl PLAYLIST',
                 'Add track(s) to iTunes playlist with PLAYLIST name')
    end

    def execute
      track_manager = TrackManager.new(@options)

      UI.say 'Getting information about track(s)'
      arg = @options[:args].pop
      tracks =
        case arg
        when 'like'
          track_manager.likes(1, 0)
        when 'post'
          track_manager.posts(1, 0)
        when 'likes'
          count = @options[:args].pop.to_i
          track_manager.likes(count, 0)
        when 'posts'
          count = @options[:args].pop.to_i
          track_manager.posts(count, 0)
        when %r{https:\/\/soundcloud.com\/}
          track_manager.track_from_url(arg)
        when nil
          UI.term 'You must provide argument'
        else
          UI.term "Invalid argument/option '#{arg}'"
        end

      UI.term 'There are no tracks yet' if tracks.nil?

      track_manager.process_tracks(tracks)
    end

    def arguments
      { 'post'         => 'Get last post (track or repost) from your profile',
        'NUMBER posts' => 'Get last NUMBER posts from your profile',
        'like'         => 'Get your last like',
        'NUMBER likes' => 'Get your last NUMBER likes',
        'URL'          => 'Get track from entered URL' }
    end

    def program_name
      'nehm get'
    end

    def summary
      'Download tracks, set tags and add to your iTunes library tracks from SoundCloud'
    end

    def usage
      "#{program_name} ARGUMENT [OPTIONS]"
    end

  end
end
