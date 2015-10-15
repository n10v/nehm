module Nehm

  ##
  # iTunes playlist primitive

  class Playlist

    attr_reader :name

    def initialize(name)
      @name = name.chomp
    end

    def add_track(track)
      UI.say 'Adding to iTunes'
      AppleScript.add_track_to_playlist(track.file_path, @name)
    end

    def to_s
      @name
    end

  end
end
