# Configure module responds to 'nehm configure' command
module Configure
  def self.menu
    loop do
      output = ''

      # Download path
      output << 'Download path: '
      output <<
        if Config[:dl_path]
          Paint[Config[:dl_path], :magenta]
        else
          Paint["doesn't set up", :gold]
        end
      output << "\n"

      # iTunes path
      output << 'iTunes path: '
      output <<
        if PathControl.itunes_path
          Paint[PathControl.itunes_path_name, :magenta]
        else
          Paint["doesn't set up", :gold]
        end
      output << "\n"

      # Permalink
      output << 'Permalink: '
      output <<
        if Config[:permalink]
          Paint[Config[:permalink], :cyan]
        else
          Paint["doesn't set up", :gold]
        end
      output << "\n"

      # Playlist
      output << 'Playlist: '
      output <<
        if PlaylistControl.playlist
          Paint[PlaylistControl.playlist, :cyan]
        else
          Paint["doesn't set up", :gold]
        end
      output << "\n"

      puts output

      HighLine.new.choose do |menu|
        menu.prompt = Paint['Choose setting', :yellow]

        menu.choice('Edit download path'.freeze) { PathControl.set_dl_path }
        menu.choice('Edit iTunes path'.freeze) { PathControl.set_itunes_path } unless OS.linux?
        menu.choice('Edit permalink'.freeze) { UserControl.log_in }
        menu.choice('Edit iTunes playlist'.freeze) { PlaylistControl.set_playlist } unless OS.linux?
        menu.choice('Exit'.freeze) { exit }
      end
      puts "\n"
    end
  end
end
