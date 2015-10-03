require 'highline'

require 'nehm/applescript'
require 'nehm/argument_parser'
require 'nehm/artwork'
require 'nehm/cfg'
require 'nehm/command'
require 'nehm/command_manager'
require 'nehm/configure'
require 'nehm/client'
require 'nehm/get'
require 'nehm/help'
require 'nehm/os'
require 'nehm/path_manager'
require 'nehm/playlist'
require 'nehm/playlist_manager'
require 'nehm/track'
require 'nehm/ui'
require 'nehm/user'
require 'nehm/user_manager'
require 'nehm/version'

module Nehm
  def self.start(args)
    init unless initialized?

    CommandManager.run(args)
  end

  module_function

  def init
    puts 'Hello!'.green
    puts 'Before using the nehm, you should set it up:'
    Cfg.create unless Cfg.exist?

    PathManager.set_dl_path
    puts "\n"

    unless OS.linux?
      PlaylistManager.set_playlist
      puts "\n"
    end

    UserManager.set_uid
    puts "\n"

    puts "Now you can use nehm!\n".green
    sleep(1)
  end

  def initialized?
    File.exist?(Cfg::FILE_PATH)
  end
end
