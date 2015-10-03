require 'taglib'

module Nehm
  # Get module responds to 'nehm get/dl ...' commands
  module Get
    def self.[](type, args)
      # Processing arguments
      options = ArgumentProcessor.get(args)

      # Setting up user id
      temp_uid = options['from']
      uid = temp_uid ? UserManager.get_id(temp_uid) : UserManager.default_id
      unless uid
        puts "You didn't logged in".red
        puts "Login from #{'nehm configure'.yellow} or use #{'[from PERMALINK]'.yellow} option"
        exit
      end

      # Setting up iTunes playlist
      if type == :get && !OS.linux?
        playlist_name = options['playlist']
        playlist = temp_playlist ? PlaylistManager.get_playlist(playlist_name) : PlaylistManager.default_playlist
        itunes_playlist_ready = true if playlist
      else
        itunes_playlist_ready = false
      end

      # Setting up download path
      temp_path = options['to']
      dl_path = temp_path ? PathManager.get_path(temp_path) : PathManager.default_dl_path
      if dl_path
        ENV['dl_path'] = dl_path
      else
        puts "You don't set up download path!".red
        puts "Set it up from #{'nehm configure'.yellow} or use #{'[to PATH_TO_DIRECTORY]'.yellow} option"
        exit
      end

      puts 'Getting information about track(s)'
      tracks = []
      tracks +=
        case args.last
        when 'like'
          likes(1, uid)
        when 'post'
          posts(1, uid)
        when 'likes'
          count = args[-2].to_i
          likes(count, uid)
        when 'posts'
          count = args[-2].to_i
          posts(count, uid)
        when %r{https:\/\/soundcloud.com\/}
          track(args.last)
        when nil
          puts 'You must provide option'.red
          puts "Input #{'nehm help'.yellow} for help"
          exit
        else
          puts "Invalid argument(s) '#{args.last}'".red
          puts "Input #{'nehm help'.yellow} for help"
          exit
        end

      tracks.each do |track|
        puts "\n"
        dl(track)
        tag(track)
        track.artwork.suicide
        playlist.add_track(track.file_path) if itunes_playlist_ready
        puts "\n"
      end
      puts 'Done!'.green
    end

    module_function

    def dl(track)
      # Downloading track
      puts 'Downloading ' + track.full_name
      `curl -# -o \"#{track.file_path}\" -L #{track.url}`

      # Downloading artwork
      puts 'Downloading artwork'
      artwork = track.artwork
      `curl -# -o \"#{artwork.file_path}\" -L #{artwork.url}`
    end

    def tag(track)
      puts 'Setting tags'
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
      abort 'There are no likes yet'.red if likes.empty?

      # Removing playlists and unstreamable tracks
      unstreamable_tracks = likes.reject! { |hash| hash['streamable'] == false }
      puts "Was skipped #{unstreamable_tracks.length} undownloadable track(s)".yellow if unstreamable_tracks

      likes.map! { |hash| Track.new(hash) }
    end

    def posts(count, uid)
      posts = Client.tracks(count, :posts, uid)
      abort 'There are no posts yet'.red if posts.empty?

      # Removing playlists and unstreamable tracks
      playlists = posts.reject! { |hash| hash['type'] == 'playlist' }
      unstreamable_tracks = posts.reject! { |hash| hash['track']['streamable'] == false }
      puts "Was skipped #{playlists.length} playlist(s). (nehm doesn't download playlists)".yellow if playlists
      puts "Was skipped #{unstreamable_tracks.length} undownloadable track(s)".yellow if unstreamable_tracks

      posts.map! { |hash| Track.new(hash['track']) }
    end

    def track(url)
      hash = Client.track(url)
      [*Track.new(hash)]
    end
  end
end
