class Playlist
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def add_track(track_path)
    puts 'Adding to playlist'
    AppleScripts.add_track_to_playlist(track_path, @name)
  end
end
