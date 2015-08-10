module PathControl
  attr_reader :temp_dl_path

  def self.dl_path
    @temp_dl_path || default_dl_path
  end

  def self.set_dl_path
    loop do
      default_path = File.join(ENV['HOME'], '/Music')
      path_ask = 'Enter path to desirable download directory'

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
        puts Paint["Download directory set up to #{Paint[path, :magenta]}", :green]
        break
      else
        puts Paint["This directory doesn't exist. Please enter correct path", :red]
      end
    end
  end

  def self.temp_dl_path=(path)
    # If 'to ~/../..' entered
    path = PathControl.tilde_to_home(path) if PathControl.tilde_at_top?(path)

    # If 'to current' entered
    path = Dir.pwd if path == 'current'

    if Dir.exist?(path)
      @temp_dl_path = path
    else
      puts Paint['Invalid download path! Please enter correct path', :red]
      exit
    end
  end

  def self.itunes_path
    Config[:itunes_path]
  end

  # Use in Configure.menu
  def self.itunes_root_path
    PathControl.itunes_path.sub("/iTunes\ Media/Automatically\ Add\ to\ iTunes.localized", '')
  end

  def self.set_itunes_path
    loop do
      default_path = File.join(ENV['HOME'], '/Music/iTunes')
      path_ask = 'Enter path to iTunes directory'

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
        puts Paint["iTunes directory set up to #{Paint[PathControl.itunes_root_path, :magenta]}", :green]
        break
      else
        puts Paint["This directory doesn't exist. Please enter correct path", :red]
      end
    end
  end

  def self.set_itunes_path_to_default
    itunes_path = File.join(ENV['HOME'], "/Music/iTunes/iTunes\ Media/Automatically\ Add\ to\ iTunes.localized")
    if Dir.exist?(itunes_path)
      Config[:itunes_path] = itunes_path
    else
      puts Paint["Don't know where your iTunes path. Set it up manually from ", 'gold'] + Paint['nehm configure', :yellow]
    end
  end

  def self.tilde_to_home(path)
    File.join(ENV['HOME'], path[1..-1])
  end

  def self.tilde_at_top?(path)
    path[0] == '~'
  end

  module_function

  def default_dl_path
    if Config[:dl_path]
      Config[:dl_path]
    else
      puts Paint["You don't set up download path!", :red]
      puts "Set it up from #{Paint['nehm configure', :yellow]} or use #{Paint['[to PATH_TO_DIRECTORY]', :yellow]} option"
      exit
    end
  end
end
