require 'taglib'

module Nehm

  ##
  # Tracks contains logic, that need to 'nehm get/dl ...' commands.
  #
  # It used in 'get_command.rb' and 'dl_command.rb'.

  module Tracks

    ##
    # Main method.

    def self.[](type, options)
      # Setting up user id
      permalink = options[:from]
      uid = permalink ? UserManager.get_id(permalink) : UserManager.default_uid
      unless uid
        UI.error "You didn't logged in"
        UI.say "Login from #{'nehm configure'.yellow} or use #{'[from PERMALINK]'.yellow} option"
        UI.term
      end

      # Setting up iTunes playlist
      if type == :get && !OS.linux?
        playlist_name = options[:playlist]
        playlist = playlist_name ? PlaylistManager.get_playlist(playlist_name) : PlaylistManager.default_playlist
        itunes_playlist_ready = true if playlist
      else
        itunes_playlist_ready = false
      end

      # Setting up download path
      temp_path = options[:to]
      dl_path = temp_path ? PathManager.get_path(temp_path) : PathManager.default_dl_path
      if dl_path
        ENV['dl_path'] = dl_path
      else
        UI.error "You don't set up download path!"
        UI.say "Set it up from #{'nehm configure'.yellow} or use #{'[to PATH_TO_DIRECTORY]'.yellow} option"
        UI.term
      end

      UI.say 'Getting information about track(s)'
      arg = options[:args].pop
      tracks = []
      tracks +=
        case arg
        when 'like'
          likes(1, uid)
        when 'post'
          posts(1, uid)
        when 'likes'
          count = options[:args].pop.to_i
          likes(count, uid)
        when 'posts'
          count = options[:args].pop.to_i
          posts(count, uid)
        when %r{https:\/\/soundcloud.com\/}
          track(options[:args].pop)
        when nil
          UI.error 'You must provide argument'
          UI.say "Use #{'nehm help'.yellow} for help"
          UI.term
        else
          UI.error "Invalid argument/option #{arg}"
          UI.say "Use #{'nehm help'.yellow} for help"
          UI.term
        end

      tracks.each do |track|
        UI.newline
        dl(track)
        tag(track)
        track.artwork.suicide
        playlist.add_track(track.file_path) if itunes_playlist_ready
        UI.newline
      end
      UI.success 'Done!'
    end

    module_function

    def dl(track)
      # Downloading track
      UI.say 'Downloading ' + track.full_name
      `curl -# -o \"#{track.file_path}\" -L #{track.url}`

      # Downloading artwork
      UI.say 'Downloading artwork'
      artwork = track.artwork
      `curl -# -o \"#{artwork.file_path}\" -L #{artwork.url}`
    end

    def tag(track)
      UI.say 'Setting tags'
      path = track.file_path
      TagLib::MPEG::File.open(path) do |file|
        tag = file.id3v2_tag
        tag.artist = track.artist
        tag.title = track.title
        tag.year = track.year

        # Adding artwork
        apic = TagLib::ID3v2::AttachedPictureFrame.new
        apic.mime_type = 'image/jpeg'
        apic.description = 'Cover'
        apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
        apic.picture = File.open(track.artwork.file_path, 'rb') { |f| f.read }
        tag.add_frame(apic)

        file.save
      end
    end

    def likes(count, uid)
      likes = Client.tracks(count, :likes, uid)
      UI.term 'There are no likes yet' if likes.empty?

      # Removing playlists and unstreamable tracks
      unstreamable_tracks = likes.reject! { |hash| hash['streamable'] == false }
      UI.warning "Was skipped #{unstreamable_tracks.length} undownloadable track(s)" if unstreamable_tracks

      likes.map! { |hash| Track.new(hash) }
    end

    def posts(count, uid)
      posts = Client.tracks(count, :posts, uid)
      UI.term 'There are no posts yet' if posts.empty?

      # Removing playlists and unstreamable tracks
      first_count = posts.length
      playlists = posts.reject! { |hash| hash['type'] == 'playlist' }
      unstreamable_tracks = posts.reject! { |hash| hash['track']['streamable'] == false }
      if playlists || unstreamable_tracks
        UI.newline
        UI.warning "Was skipped #{first_count - posts.length} undownloadable track(s) or playlist(s)"
      end

      posts.map! { |hash| Track.new(hash['track']) }
    end

    def track(url)
      hash = Client.track(url)
      [*Track.new(hash)]
    end

  end
end
