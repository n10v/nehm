require_relative 'nehm/os.rb'
require_relative 'nehm/track_utils.rb'
require_relative 'nehm/path_control.rb'
require_relative 'nehm/user_control.rb'
require_relative 'nehm/config.rb'
require_relative 'nehm/configure.rb'
require_relative 'nehm/help.rb'
module App

  # Public

  def self.do(args)
    init unless initialized?

    command = args.shift
    case command
    when 'get'
      TrackUtils.get(:get, args)
    when 'dl'
      TrackUtils.get(:dl, args)
    when 'configure'
      Configure.menu
    when 'login'
      UserControl.log_in
    when 'init'
      init
    when 'help'
      Help.show(args.first)
    else
      puts Paint['Invalid command', :red]
      puts "Input #{Paint['nehm help', :yellow]} for all avalaible commands"
    end
  end

  # Private

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
