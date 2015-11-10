require 'colored'

require 'nehm/client'
require 'nehm/cfg'
require 'nehm/command_manager'
require 'nehm/os'
require 'nehm/path_manager'
require 'nehm/playlist_manager'
require 'nehm/track_manager'
require 'nehm/ui'
require 'nehm/user_manager'

module Nehm

  def self.start(args)
    init unless initialized?

    CommandManager.run(args)
  end

  module_function

  def init
    UI.say 'Hello!'.green
    UI.say 'Before using the nehm, you should set it up:'
    Cfg.create unless Cfg.exist?

    PathManager.set_dl_path
    UI.newline

    UserManager.set_uid
    UI.newline

    if OS.mac?
      PlaylistManager.set_playlist
      UI.newline
    end

    UI.success "Now you can use nehm!"
    UI.newline

    sleep(UI::SLEEP_PERIOD)
  end

  def initialized?
    Cfg.exist?
  end

end
