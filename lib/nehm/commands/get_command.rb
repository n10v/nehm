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
      # Setting up user id
      permalink = @options[:from]
      uid = permalink ? UserManager.get_uid(permalink) : UserManager.default_uid
      unless uid
        UI.error "You didn't logged in"
        UI.say "Login from #{'nehm configure'.yellow} or use #{'[from PERMALINK]'.yellow} option"
        UI.term
      end

      # Setting up iTunes playlist
      playlist = nil
      if !@options[:dl] && !OS.linux?
        playlist_name = @options[:playlist]
        playlist = playlist_name ? PlaylistManager.get_playlist(playlist_name) : PlaylistManager.default_playlist
      end

      # Setting up download path
      temp_path = @options[:to]
      dl_path = temp_path ? PathManager.get_path(temp_path) : PathManager.default_dl_path
      if dl_path
        ENV['dl_path'] = dl_path
      else
        UI.error "You don't set up download path!"
        UI.say "Set it up from #{'nehm configure'.yellow} or use #{'[to PATH_TO_DIRECTORY]'.yellow} option"
        UI.term
      end

      UI.say 'Getting information about track(s)'
      track_manager = TrackManager.new(playlist: playlist, uid: uid)
      arg = @options[:args].pop
      tracks = []
      tracks +=
        case arg
        when 'like'
          track_manager.likes(1)
        when 'post'
          track_manager.posts(1)
        when 'likes'
          count = @options[:args].pop.to_i
          track_manager.likes(count)
        when 'posts'
          count = @options[:args].pop.to_i
          track_manager.posts(count)
        when %r{https:\/\/soundcloud.com\/}
          track_manager.track_from_url(arg)
        when nil
          UI.error 'You must provide argument'
          UI.say "Use #{'nehm help'.yellow} for help"
          UI.term
        else
          UI.error "Invalid argument/option #{arg}"
          UI.say "Use #{'nehm help'.yellow} for help"
          UI.term
        end

      track_manager.process_tracks(tracks)

      UI.success 'Done!'
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
