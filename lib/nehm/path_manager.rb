module Nehm

  ##
  # Path manager works with download paths

  module PathManager

    def self.default_dl_path
      Cfg[:dl_path]
    end

    ##
    # Checks path for validation and returns it if valid

    def self.get_path(path)
      # Check path for existence
      UI.term 'Invalid download path! Please enter correct path' unless Dir.exist?(path)

      File.expand_path(path)
    end

    def self.set_dl_path
      loop do
        ask_sentence = 'Enter path to desirable download directory'
        default_path = File.join(ENV['HOME'], '/Music')

        if Dir.exist?(default_path)
          ask_sentence << " (press Enter to set it to #{default_path.magenta})"
        else
          default_path = nil
        end

        path = UI.ask(ask_sentence + ':')

        # If user press enter, set path to default
        path = default_path if path == '' && default_path

        if Dir.exist?(path)
          Cfg[:dl_path] = File.expand_path(path)
          UI.say "#{'Download directory set up to'.green} #{path.magenta}"
          break
        else
          UI.error "This directory doesn't exist. Please enter correct path"
        end
      end
    end

  end
end
