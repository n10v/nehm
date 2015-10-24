require 'taglib'

require 'nehm/applescript'
require 'nehm/track'

module Nehm

  class TrackManager

    def initialize(options = {})
      @playlist = options[:playlist]
      @uid = options[:uid]
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
    end

    def likes(count)
      likes = Client.tracks(count, :likes, @uid)
      UI.term 'There are no likes yet' if likes.empty?

      # Removing unstreamable tracks
      unstreamable_tracks = likes.reject! { |hash| hash['streamable'] == false }
      UI.warning "Was skipped #{unstreamable_tracks.length} undownloadable track(s)" if unstreamable_tracks

      likes.map! { |hash| Track.new(hash) }
    end

    def posts(count)
      posts = Client.tracks(count, :posts, @uid)
      UI.term 'There are no posts yet' if posts.empty?

      # Removing playlists and unstreamable tracks
      first_count = posts.length
      playlists = posts.reject! { |hash| hash['type'] == 'playlist' }
      unstreamable_tracks = posts.reject! { |hash| hash['track']['streamable'] == false }
      if playlists || unstreamable_tracks
        UI.warning "Was skipped #{first_count - posts.length} undownloadable track(s) or playlist(s)"
      end

      posts.map! { |hash| Track.new(hash['track']) }
    end

    def track_from_url(url)
      hash = Client.track(url)
      [Track.new(hash)]
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

  end
end
