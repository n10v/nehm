module PathManager
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

      # If user press enter (set path to default)
      path = default_path if path == '' && default_path

      # If tilde at top of the line of path
      path = PathManager.tilde_to_home(path) if PathManager.tilde_at_top?(path)

      if Dir.exist?(path)
        Cfg[:dl_path] = path
        puts Paint["Download directory set up to #{Paint[path, :magenta]}", :green]
        break
      else
        puts Paint["This directory doesn't exist. Please enter correct path", :red]
      end
    end
  end

  def self.temp_dl_path=(path)
    # If 'to ~/../..' entered
    path = tilde_to_home(path) if tilde_at_top?(path)

    # If 'to current' entered
    path = Dir.pwd if path == 'current'

    if Dir.exist?(path)
      @temp_dl_path = path
    else
      puts Paint['Invalid download path! Please enter correct path', :red]
      exit
    end
  end

  module_function

  def default_dl_path
    if Cfg[:dl_path]
      Cfg[:dl_path]
    else
      puts Paint["You don't set up download path!", :red]
      puts "Set it up from #{Paint['nehm configure', :yellow]} or use #{Paint['[to PATH_TO_DIRECTORY]', :yellow]} option"
      exit
    end
  end

  def tilde_at_top?(path)
    path[0] == '~'
  end

  def tilde_to_home(path)
    File.join(ENV['HOME'], path[1..-1])
  end
end
