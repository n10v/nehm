module PlaylistControl
  def self.playlist
    if @temp_playlist
      @temp_playlist
    elsif !Config[:playlist].empty?
      Playlist.new(Config[:playlist])
    end
  end

  def self.set_playlist
    loop do
      playlist = HighLine.new.ask('Enter name of default iTunes playlist to which you want add tracks (press Enter to unset default playlist)')
      if playlist == ''
        Config[:playlist] = ''
        puts Paint['Default iTunes playlist unset', :green]
        break
      end

      if AppleScript.list_of_playlists.include? playlist
        Config[:playlist] = playlist
        puts Paint["Default iTunes playlist set up to #{playlist}", :green]
        break
      else
        puts Paint['Invalid playlist name. Please enter correct playlist name', :red]
      end
    end
  end

  def self.temp_playlist=(playlist)
    if AppleScript.list_of_playlists.include? playlist
      @temp_playlist = Playlist.new(playlist)
    else
      puts Paint['Invalid playlist name. Please enter correct playlist name', :red]
      exit
    end
  end
end
