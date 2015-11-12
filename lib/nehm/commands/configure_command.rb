module Nehm
  class ConfigureCommand < Command

    def execute
      loop do
        show_info
        UI.newline
        show_menu
        UI.sleep
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

    def show_info
      dl_path = PathManager.default_dl_path
      UI.say "Download path: #{dl_path.magenta}" if dl_path

      permalink = UserManager.default_permalink
      UI.say "Permalink: #{permalink.cyan}" if permalink

      if OS.mac?
        playlist = PlaylistManager.default_playlist
        UI.say "iTunes playlist: #{playlist.to_s.cyan}" if playlist
      end
    end

    def show_menu
      UI.menu do |menu|
        menu.choice(:inc, 'Edit download path'.freeze) { PathManager.set_dl_path }
        menu.choice(:inc, 'Edit permalink'.freeze) { UserManager.set_uid }
        menu.choice(:inc, 'Edit iTunes playlist'.freeze) { PlaylistManager.set_playlist } if OS.mac?
      end
    end

  end
end
