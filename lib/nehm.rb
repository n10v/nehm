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

  class NehmExit < SystemExit; end

  def self.start(args)
    begin
      init unless initialized?

      if args.empty?
        UI.say HELP
        UI.term
      end

      CommandManager.run(args)
    rescue StandardError, Timeout::Error => ex
      Nehm::UI.term "While executing nehm ... (#{ex.class})\n    #{ex}"
    rescue Interrupt
    rescue NehmExit
    end
  end

  HELP = <<-EOF
#{'nehm'.green} is a console tool, which downloads, sets IDv3 tags (and adds to your iTunes library) your SoundCloud posts or likes in convenient way

#{'Available nehm commands:'.yellow}
  #{'get'.green}        Download, set tags and add to your iTunes library last post(s) or like(s) from your profile
  #{'dl'.green}         Download and set tags last post(s) or like(s) from your profile
  #{'configure'.green}  Configure application
  #{'help'.green}       Show help for specified command
  #{'search'.green}     Search tracks, print them nicely and download selected tracks
  #{'select'.green}     Get likes or posts from your account, nicely print them and download selected tracks
  #{'version'.green}    Show version of installed nehm

See #{'nehm help COMMAND'.yellow} to read about a specific command

Commands and arguments (but NOT options) may be abbreviated, so long as they are unambiguous.
e.g. 'nehm g l' is short for 'nehm get like'.
EOF

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

    UI.success 'Now you can use nehm!'
    UI.newline

    UI.sleep
  end

  def initialized?
    Cfg.exist?
  end

end
