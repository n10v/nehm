module PlaylistManager
  def self.playlist
    @temp_playlist || default_user_playlist || music_master_library
  end

  def self.set_playlist
    loop do
      playlist = HighLine.new.ask('Enter name of default iTunes playlist to which you want add tracks (press Enter to set it to default iTunes Music library)')
      if playlist == ''
        Cfg[:playlist] = nil
        puts Paint['Default iTunes playlist unset', :green]
        break
      end

      if AppleScript.list_of_playlists.include? playlist
        Cfg[:playlist] = playlist
        puts Paint["Default iTunes playlist set up to #{playlist}", :green]
        break
      else
        puts Paint['Invalid playlist name. Please enter correct name', :red]
      end
    end
  end

  def self.temp_playlist=(playlist)
    if AppleScript.list_of_playlists.include? playlist
      @temp_playlist = Playlist.new(playlist)
    else
      puts Paint['Invalid playlist name. Please enter correct name', :red]
      exit
    end
  end

  module_function

  def default_user_playlist
    Playlist.new(Cfg[:playlist]) unless Cfg[:playlist].nil?
  end

  def music_master_library
    Playlist.new(AppleScript.music_master_library)
  end
end
