module Nehm
  class ConfigureCommand < Command

    def execute
      loop do
        UI.say "Download path: #{Cfg[:dl_path].magenta}" if Cfg[:dl_path]
        UI.say "Permalink: #{Cfg[:permalink].cyan}" if Cfg[:permalink]
        UI.say "iTunes playlist: #{PlaylistManager.default_playlist.to_s.cyan}" if !OS.linux? && PlaylistManager.default_playlist
        UI.newline

        show_menu

        sleep(1)
        UI.newline
      end
    end

    def program_name
      'nehm configure'
    end

    def summary
      'Configure nehm app'
    end

    def usage
      'nehm configure'
    end

    private

    def show_menu
      HighLine.new.choose do |menu|
        menu.prompt = 'Choose setting'.yellow

        menu.choice('Edit download path'.freeze) { PathManager.set_dl_path }
        menu.choice('Edit permalink'.freeze) { UserManager.set_uid }
        menu.choice('Edit iTunes playlist'.freeze) { PlaylistManager.set_playlist } unless OS.linux?
        menu.choice('Exit'.freeze) { fail Interrupt }
      end
    end

  end
end
