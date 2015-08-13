# Configure module responds to 'nehm configure' command
module Configure
  def self.menu
    loop do
      output = ''
      options = [['Download path', Config[:dl_path], :magenta],
                 ['Permalink', Config[:permalink], :cyan],
                 ['iTunes path', PathControl.itunes_root_path, :magenta],
                 ['iTunes playlist', PlaylistControl.playlist, :cyan]]

      options.each do |option|
        # option[0] - name
        # option[1] - value
        # option[2] - color
        output << option[0] + ': '
        output <<
          if option[1] && !option[1].to_s.empty?
            Paint[option[1], option[2]]
          else
            Paint["doesn't set up", 'gold']
          end
        output << "\n"
      end

      puts output
      puts "\n"

      HighLine.new.choose do |menu|
        menu.prompt = Paint['Choose setting', :yellow]

        menu.choice('Edit download path'.freeze) { PathControl.set_dl_path }
        menu.choice('Edit permalink'.freeze) { UserControl.log_in }
        menu.choice('Edit iTunes path'.freeze) { PathControl.set_itunes_path } unless OS.linux?
        menu.choice('Edit iTunes playlist'.freeze) { PlaylistControl.set_playlist } unless OS.linux?
        menu.choice('Exit'.freeze) { puts 'Goodbye!'; exit }
      end
      puts "\n"
    end
  end
end
