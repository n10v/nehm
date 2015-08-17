# Configure module responds to 'nehm configure' command
module Configure
  def self.menu
    loop do
      puts 'Download path: ' + Paint[Config[:dl_path], :magenta]
      puts 'Permalink: ' + Paint[Config[:permalink], :cyan]
      puts 'iTunes playlist: ' + Paint[PlaylistControl.playlist, :cyan] unless OS.linux?
      puts "\n"
      
      HighLine.new.choose do |menu|
        menu.prompt = Paint['Choose setting', :yellow]

        menu.choice('Edit download path'.freeze) { PathControl.set_dl_path }
        menu.choice('Edit permalink'.freeze) { UserControl.log_in }
        menu.choice('Edit iTunes playlist'.freeze) { PlaylistControl.set_playlist } unless OS.linux?
        menu.choice('Exit'.freeze) { puts 'Goodbye!'; exit }
      end
      puts "\n"
    end
  end
end
