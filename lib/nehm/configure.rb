# Configure module responds to 'nehm configure' command
module Configure
  def self.menu
    loop do
      puts "Download path: #{Paint[Cfg[:dl_path], :magenta]}"
      puts "Permalink: #{Paint[Cfg[:permalink], :cyan]}"
      puts "iTunes playlist: #{Paint[PlaylistManager.playlist, :cyan]}" unless OS.linux?
      puts "\n"

      HighLine.new.choose do |menu|
        menu.prompt = Paint['Choose setting', :yellow]

        menu.choice('Edit download path'.freeze) { PathManager.set_dl_path }
        menu.choice('Edit permalink'.freeze) { UserManager.log_in }
        menu.choice('Edit iTunes playlist'.freeze) { PlaylistManager.set_playlist } unless OS.linux?
        menu.choice('Exit'.freeze) { puts 'Goodbye!'; exit }
      end
      sleep(1)
      puts "\n"
    end
  end
end
