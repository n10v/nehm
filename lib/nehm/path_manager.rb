module Nehm
  module PathManager
    def self.dl_path
      @temp_dl_path || default_dl_path
    end

    def self.set_dl_path
      loop do
        default_path = File.join(ENV['HOME'], '/Music')
        ask_sentence = 'Enter path to desirable download directory'

        if Dir.exist?(default_path)
          ask_sentence << " (press enter to set it to #{default_path.magenta})"
        else
          default_path = nil
        end

        path = HighLine.new.ask(ask_sentence + ':')

        # If user press enter, set path to default
        path = default_path if path == '' && default_path

        # If tilde at top of the line of path
        path = PathManager.tilde_to_home(path) if PathManager.tilde_at_top?(path)

        if Dir.exist?(path)
          Cfg[:dl_path] = path
          puts "#{'Download directory set up to'.green} #{path.magenta}"
          break
        else
          puts "This directory doesn't exist. Please enter correct path".red
          puts "\n"
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
        puts 'Invalid download path! Please enter correct path'.red
        exit
      end
    end

    module_function

    def default_dl_path
      if Cfg[:dl_path]
        Cfg[:dl_path]
      else
        puts "You don't set up download path!".red
        puts "Set it up from #{'nehm configure'.yellow} or use #{'[to PATH_TO_DIRECTORY]'.yellow} option"
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
end
