module Nehm
  # Help module responds to 'nehm help ...' command
  module Help
    def self.available_commands
      puts <<-HELP.gsub(/^ {8}/, '')
        #{'nehm'.green} is a console tool, which downloads, sets IDv3 tags and adds to your iTunes library your SoundCloud posts or likes in convenient way

        #{'Avalaible nehm commands:'.yellow}
          #{'get'.green}        Download, set tags and add to your iTunes library last post or like from your profile
          #{'dl'.green}         Download and set tags last post or like from your profile
          #{'configure'.green}  Configure application
          #{'version'.green}    Show version of installed nehm

        See #{'nehm help [command]'.yellow} to read about a specific subcommand
      HELP
    end

    def self.show(command)
      case command
      when 'get', 'dl', 'configure', 'permalink'
        Help.send(command)
      when nil
        Help.available_commands
      else
        puts "Command '#{command}' doesn't exist".red
        puts "\n"
        Help.available_commands
      end
    end

    module_function

    def configure
      puts <<-CONFIGURE.gsub(/^ {8}/, '')
        #{'Input:'.yellow} nehm configure

        #{'Summary:'.yellow}
          Configuring nehm app
        CONFIGURE
    end

    def dl
      puts <<-DL.gsub(/^ {8}/, '')
        #{'Input:'.yellow} nehm dl OPTIONS [from PERMALINK] [to PATH_TO_DIRECTORY] [playlist ITUNES_PLAYLIST]

        #{'Summary:'.yellow}
          Download tracks from SoundCloud and setting tags

        #{'OPTIONS:'.yellow}
          #{'post'.green}                       Do same with last post (track or repost) from your profile
          #{'<number> posts'.green}             Do same with last <number> posts from your profile
          #{'like'.green}                       Do same with your last like
          #{'<number> likes'.green}             Do same with your last <number> likes
          #{'url'.magenta}                        Do same with track from entered url

        #{'Extra options:'.yellow}
          #{'from PERMALINK'.green}             Do aforecited operations from custom user profile
          #{'to PATH_TO_DIRECTORY'.green}       Do aforecited operations to custom directory
          #{'to current'.green}                 Do aforecited operations to current working directory
          #{'playlist ITUNES_PLAYLIST'.green}   Do aforecited operations to custom iTunes playlist
      DL
    end

    def get
      puts <<-GET.gsub(/^ {8}/, '')
        #{'Input:'.yellow} nehm get OPTIONS [from PERMALINK] [to PATH_TO_DIRECTORY] [playlist ITUNES_PLAYLIST]

        #{'Summary:'.yellow}
          Download tracks, set tags and add to your iTunes library tracks from Soundcloud

        #{'OPTIONS:'.yellow}
          #{'post'.green}                       Do same with last post (track or repost) from your profile
          #{'<number> posts'.green}             Do same with last <number> posts from your profile
          #{'like'.green}                       Do same with your last like
          #{'<number> likes'.green}             Do same with your last <number> likes
          #{'url'.magenta}                        Do same with track from entered url

        #{'Extra options:'.yellow}
          #{'from PERMALINK'.green}             Do aforecited operations from profile with PERMALINK
          #{'to PATH_TO_DIRECTORY'.green}       Do aforecited operations to custom directory
          #{'to current'.green}                 Do aforecited operations to current working directory
          #{'playlist ITUNES_PLAYLIST'.green}   Do aforecited operations to custom iTunes playlist
      GET
    end

    def permalink
      puts <<-PERM.gsub(/^ {8}/, '')
        Permalink is the last word in your profile url
        Example: for profile url #{'soundcloud.com/qwerty'.magenta} permalink is #{'qwerty'.magenta}
      PERM
    end
  end
end
