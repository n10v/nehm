require 'highline'
require 'paint'

require 'nehm/applescript'
require 'nehm/artwork'
require 'nehm/cfg'
require 'nehm/configure'
require 'nehm/client'
require 'nehm/get'
require 'nehm/help'
require 'nehm/os'
require 'nehm/path_manager'
require 'nehm/playlist'
require 'nehm/playlist_manager'
require 'nehm/track'
require 'nehm/user'
require 'nehm/user_manager'
require 'nehm/version'

module Nehm
  module App
    def self.do(args)
      init unless initialized?

      command = args.shift
      case command
      when 'get'
        Get[:get, args]
      when 'dl'
        Get[:dl, args]
      when 'configure'
        Configure.menu
      when 'version'
        puts Nehm::VERSION
      when 'help', nil
        Help.show(args.first)
      else
        puts Paint["Invalid command '#{command}'", :red]
        puts "Input #{Paint['nehm help', :yellow]} for all avalaible commands"
      end

      # SIGINT
      rescue Interrupt
        puts "\nGoodbye!"
    end

    module_function

    def init
      puts Paint['Hello!', :green]
      puts 'Before using the nehm, you should set it up:'
      Cfg.create unless Cfg.exist?

      PathManager.set_dl_path
      puts "\n"

      unless OS.linux?
        PlaylistManager.set_playlist
        puts "\n"
      end

      UserManager.log_in

      puts Paint["Now you can use nehm!\n", :green]
    end

    def initialized?
      File.exist?(Cfg::FILE_PATH)
    end
  end
end
