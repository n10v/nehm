module Nehm
  # Configure module responds to 'nehm configure' command
  module Configure
    def self.menu
      loop do
        puts "Download path: #{Cfg[:dl_path].magenta}" if Cfg[:dl_path]
        puts "Permalink: #{Cfg[:permalink].cyan}" if Cfg[:permalink]
        puts "iTunes playlist: #{PlaylistManager.playlist.to_s.cyan}" if !OS.linux? && PlaylistManager.playlist
        puts "\n"

        HighLine.new.choose do |menu|
          menu.prompt = 'Choose setting'.yellow

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
end
