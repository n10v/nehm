require 'colored'
require 'highline'

require 'nehm/applescript'
require 'nehm/artwork'
require 'nehm/cfg'
require 'nehm/command'
require 'nehm/command_manager'
require 'nehm/configure'
require 'nehm/client'
require 'nehm/get'
require 'nehm/help'
require 'nehm/option_parser'
require 'nehm/os'
require 'nehm/path_manager'
require 'nehm/playlist'
require 'nehm/playlist_manager'
require 'nehm/track'
require 'nehm/ui'
require 'nehm/user_manager'
require 'nehm/version'

module Nehm
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
