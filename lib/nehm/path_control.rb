class PathControl
  def self.dl_path
    @temp_dl_path ? @temp_dl_path : Config[:dl_path]
  end

  def self.set_dl_path
    loop do
      default_path = File.join(ENV['HOME'], '/Music')
      path_ask = 'Enter a FULL path to default download directory'

      if Dir.exist?(default_path)
        path_ask << " (press enter to set it to #{Paint[default_path, :magenta]})"
      else
        default_path = nil
      end

      path = HighLine.new.ask(path_ask + ':')
      path = default_path if path == '' && default_path

      path = PathControl.tilde_to_home(path) if PathControl.tilde_at_top?(path)

      if Dir.exist?(path)
        Config[:dl_path] = path
        puts Paint['Download directory set up!', :green]
        break
      else
        puts Paint["This directory doesn't exist. Please enter path again", :red]
      end
    end
  end

  def self.temp_dl_path=(path)
    if Dir.exist?(path)
      @temp_dl_path = path
    else
      puts Paint['Invalid path!', :red]
      exit
    end
  end

  def self.itunes_path
    Config[:itunes_path]
  end

  # Use in Configure.menu
  def self.itunes_path_name
    PathControl.itunes_path.sub("/iTunes\ Media/Automatically\ Add\ to\ iTunes.localized", '')
  end

  def self.set_itunes_path
    loop do
      default_path = File.join(ENV['HOME'], '/Music/iTunes')
      path_ask = 'Enter a FULL path to iTunes directory'

      if Dir.exist?(default_path)
        path_ask << " (press enter to set it to #{Paint[default_path, :magenta]})"
      else
        default_path = nil
      end

      path = HighLine.new.ask(path_ask + ':')
      path = default_path if path == '' && default_path

      path = PathControl.tilde_to_home(path) if PathControl.tilde_at_top?(path)

      path = File.join(path, "iTunes\ Media/Automatically\ Add\ to\ iTunes.localized")

      if Dir.exist?(path)
        Config[:itunes_path] = path
        puts Paint['iTunes directory set up!', :green]
        break
      else
        puts Paint["This directory doesn't exist. Please enter path again", :red]
      end
    end
  end

  def self.tilde_to_home(path)
    File.join(ENV['HOME'], path[1..-1])
  end

  def self.tilde_at_top?(path)
    path[0] == '~' ? true : false
  end
end
