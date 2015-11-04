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

  # TODO: add rake tests

  def self.start(args)
    init unless initialized?

    CommandManager.run(args)
  end

  module_function

  def init
    UI.success 'Hello!'
    UI.say 'Before using the nehm, you should set it up:'
    Cfg.create unless Cfg.exist?

    PathManager.set_dl_path
    UI.newline

    unless OS.linux?
      PlaylistManager.set_playlist
      UI.newline
    end

    UserManager.set_uid
    UI.newline

    UI.success "Now you can use nehm!\n"
    sleep(1)
  end

  def initialized?
    File.exist?(Cfg::FILE_PATH)
  end

end
