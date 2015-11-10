require 'taglib'

require 'nehm/applescript'
require 'nehm/track'

module Nehm

  class TrackManager

    def initialize(options)
      setup_environment(options)
    end

    def process_tracks(tracks)
      tracks.reverse_each do |track|
        UI.newline
        dl(track)
        tag(track)
        track.artwork.suicide
        @playlist.add_track(track) if @playlist
        UI.newline
      end
      UI.success 'Done!'
    end

    def likes(limit, offset)
      likes = Client.tracks(limit, offset, :likes, @uid)
      return nil if likes.empty?

      filter(likes)
      convert(likes)
    end

    def posts(limit, offset)
      posts = Client.tracks(limit, offset, :posts, @uid)
      return nil if posts.empty?

      posts.reject! { |hash| hash['type'] == 'playlist' }
      posts.map! { |hash| hash['track'] }
      filter(posts)
      convert(posts)
    end

    def track_from_url(url)
      track = [Client.track(url)]
      return nil if track.empty?

      filter(track)
      convert(track)
    end

    def search(query, limit, offset)
      found = Client.search(query, limit, offset)
      return nil if found.empty?

      filter(found)
      convert(found)
    end

    private

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
      TagLib::MPEG::File.open(track.file_path) do |file|
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

    def setup_environment(options)
      # Setting up user id
      permalink = options[:from]
      @uid = permalink ? UserManager.get_uid(permalink) : UserManager.default_uid
      unless @uid
        UI.error "You didn't logged in"
        UI.say "Login from #{'nehm configure'.yellow} or use #{'[from PERMALINK]'.yellow} option"
        UI.term
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

      # Setting up iTunes playlist
      @playlist = nil
      if !options[:dl] && OS.mac?
        playlist_name = options[:playlist]
        @playlist = playlist_name ? PlaylistManager.get_playlist(playlist_name) : PlaylistManager.default_playlist
      end
    end

    def filter(tracks)
      # Removing unstreamable tracks
      first_length = tracks.length
      tracks.select! { |hash| hash['streamable'] }
      diff = first_length - tracks.length

      UI.warning "Was skipped #{diff} undownloadable track(s)" if diff > 0
    end

    def convert(tracks)
      tracks.map! { |hash| Track.new(hash) }
    end

  end
end
