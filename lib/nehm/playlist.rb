module Nehm
  class Playlist
    attr_reader :name

    def initialize(name)
      @name = name.chomp
    end

    def add_track(track_path)
      puts 'Adding to iTunes'
      AppleScript.add_track_to_playlist(track_path, @name)
    end

    def to_s
      @name
    end
  end
end
