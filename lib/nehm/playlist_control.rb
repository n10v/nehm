require 'nehm/applescripts'
module PlaylistControl
  def self.playlist
    @temp_playlist || Config[:playlist]
  end

  def self.set_playlist
    loop do
      playlist = Highline.new.ask('Enter name of default iTunes playlist to which you want add tracks')

      if AppleScripts.list_of_playlists.include? playlist
        Config[:playlist] = playlist
        puts Paint["Default iTunes playlist set up to #{playlist}", :green]
        break
      else
        puts Paint['Invalid playlist name. Please enter correct playlist name', :red]
      end
    end
  end

  def self.temp_playlist=(playlist)
    if AppleScripts.list_of_playlists.include? playlist
      @temp_playlist = Playlist.new(playlist)
    else
      puts Paint['Invalid playlist name. Please enter correct playlist name', :red]
      exit
    end
  end
end
