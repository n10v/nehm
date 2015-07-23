require 'highline'
require 'paint'

require 'nehm/artwork'
require 'nehm/config'
require 'nehm/configure'
require 'nehm/client'
require 'nehm/get'
require 'nehm/help'
require 'nehm/os'
require 'nehm/path_control'
require 'nehm/track'
require 'nehm/user'
require 'nehm/user_control'

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
    when 'help'
      Help.show(args.first)
    else
      puts Paint['Invalid command', :red]
      puts "Input #{Paint['nehm help', :yellow]} for all avalaible commands"
    end
  end

  module_function

  def init
    puts Paint['Hello!', :green]
    puts 'Before using the nehm, you should set it up:'
    Config.create unless Config.exist?

    PathControl.set_dl_path
    puts "\n"

    unless OS.linux?
      PathControl.set_itunes_path
      puts "\n"
    end

    UserControl.log_in

    puts Paint['Now you can use nehm :)', :green]
  end

  def initialized?
    File.exist?(File.join(ENV['HOME'], '.nehmconfig'))
  end
end
