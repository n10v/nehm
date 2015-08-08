# Configure module responds to 'nehm configure' command
module Configure
  def self.menu
    loop do
      output = ''
      options = [{ value: Config[:dl_path], name: 'Download path', color: :magenta },
                 { value: Config[:permalink], name: 'Permalink', color: :cyan },
                 { value: PathControl.itunes_root_path, name: 'iTunes path', color: :magenta },
                 { value: PlaylistControl.playlist.name, name: 'iTunes playlist', color: :cyan }]

      options.each do |option|
        output << option[:name] + ': '
        output <<
          if option[:value]
            Paint[option[:value], option[:color]]
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
