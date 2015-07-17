require 'highline'
require 'paint'
require_relative 'user_control.rb'
require_relative 'os.rb'
require_relative 'config.rb'
require_relative 'path_control.rb'

module Configure
  def self.menu
    puts 'Download path: ' + Paint[PathControl.dl_path, :magenta]
    puts 'iTunes path: ' + Paint[PathControl.itunes_path.sub("/iTunes\ Media/Automatically\ Add\ to\ iTunes.localized", ''), :magenta] unless OS.linux?
    puts 'Permalink: ' + Paint[Config[:permalink], :cyan]
    puts "\n"

    HighLine.new.choose do |menu|
      menu.prompt = Paint['Choose setting', :yellow]

      menu.choice('Edit download path') { PathControl.set_dl_path }
      menu.choice('Edit itunes path') { PathControl.set_itunes_path } unless OS.linux?
      menu.choice('Edit permalink') { UserControl.log_in }
      menu.choice('Exit') { exit }
    end
  end
end
