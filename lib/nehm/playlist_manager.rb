require 'nehm/playlist'

module Nehm

  ##
  # Playlist manager works with iTunes playlists

  module PlaylistManager

    def self.default_playlist
      default_user_playlist || music_master_library
    end

    ##
    # Checks path for existence and returns it if exists

    def self.get_playlist(playlist_name)
      if AppleScript.list_of_playlists.include? playlist_name
        Playlist.new(playlist_name)
      else
        UI.term 'Invalid playlist name. Please enter correct name'
      end
    end

    def self.set_playlist
      loop do
        playlist = UI.ask('Enter name of default iTunes playlist to that you want add tracks (press Enter to set it to default iTunes Music library):')

        # If entered nothing, unset iTunes playlist
        if playlist == ''
          Cfg[:playlist] = nil
          UI.success 'Default iTunes playlist unset'
          break
        end

        if AppleScript.list_of_playlists.include? playlist
          Cfg[:playlist] = playlist
          UI.say "#{'Default iTunes playlist set up to'.green} #{playlist.magenta}"
          break
        else
          UI.error 'Invalid playlist name. Please enter correct name'
        end
      end
    end


    module_function

    def default_user_playlist
      Playlist.new(Cfg[:playlist]) unless Cfg[:playlist].nil?
    end

    ##
    # Music master library is main iTunes music library

    def music_master_library
      Playlist.new(AppleScript.music_master_library)
    end

  end
end
