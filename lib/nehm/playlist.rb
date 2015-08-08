require 'nehm/applescripts'
class Playlist

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def add_track(track_path)
    AppleScripts.add_track_to_playlist(track_path, @name)
  end
end
