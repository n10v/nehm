require 'nehm/applescripts'
class Playlist
  def initialize(name)
    @name = name
  end

  def add_track(file_path)
    AppleScripts.add_track_to_playlist(file_path, @name)
  end
end
