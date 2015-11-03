module Nehm

  ##
  # Path manager works with download pathes

  module PathManager

    def self.default_dl_path
      Cfg[:dl_path]
    end

    ##
    # Checks path for validation and returns it if valid

    def self.get_path(path)
      # If path begins with ~
      path = tilde_to_home(path) if tilde_at_top?(path)

      # Check path for existence
      UI.term 'Invalid download path! Please enter correct path' unless Dir.exist?(path)

      path
    end

    def self.set_dl_path
      loop do
        ask_sentence = 'Enter path to desirable download directory'
        default_path = File.join(ENV['HOME'], '/Music')

        if Dir.exist?(default_path)
          ask_sentence << " (press enter to set it to #{default_path.magenta})"
        else
          default_path = nil
        end

        path = UI.ask(ask_sentence + ':')

        # If user press enter, set path to default
        path = default_path if path == '' && default_path

        # If tilde at top of the line of path
        path = PathManager.tilde_to_home(path) if PathManager.tilde_at_top?(path)

        if Dir.exist?(path)
          Cfg[:dl_path] = path
          UI.say "#{'Download directory set up to'.green} #{path.magenta}"
          break
        else
          UI.error "This directory doesn't exist. Please enter correct path"
        end
      end
    end

    module_function

    def tilde_at_top?(path)
      path[0] == '~'
    end

    def tilde_to_home(path)
      File.join(ENV['HOME'], path[1..-1])
    end

  end
end
