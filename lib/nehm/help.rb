# Help module responds to 'nehm help ...' command
module Help
  def self.available_commands
    puts <<-HELP.gsub(/^ {6}/, '')
      #{Paint['Avalaible nehm commands:', :yellow]}
        #{Paint['get', :green]}        Downloading, setting tags and adding to your iTunes library last post or like from your profile
        #{Paint['dl', :green]}         Downloading and setting tags last post or like from your profile
        #{Paint['configure', :green]}  Configuring application
      See #{Paint['nehm help [command]', :yellow]} to read about a specific subcommand
    HELP
  end

  def self.show(command)
    case command
    when 'get', 'dl', 'configure', 'permalink'
      Help.send(command)
    when nil
      Help.available_commands
    else
      puts Paint["Command #{command} doesn't exist", :red]
      puts "\n"
      Help.available_commands
    end
  end

  module_function

  def configure
    puts <<-CONFIGURE.gsub(/^ {6}/, '')
      #{Paint['Input:', :yellow]} nehm configure

      #{Paint['Summary:', :yellow]}
        Configuring nehm app
      CONFIGURE
  end

  def dl
    puts <<-DL.gsub(/^ {6}/, '')
      #{Paint['Input:', :yellow]} nehm dl OPTIONS [from PERMALINK] [to PATH_TO_DIRECTORY] [playlist ITUNES_PLAYLIST]

      #{Paint['Summary:', :yellow]}
        Downloading tracks from SoundCloud and setting tags

      #{Paint['OPTIONS:', :yellow]}
        #{Paint['post', :green]}                       Do same with last post (track or repost) from your profile
        #{Paint['<number> posts', :green]}             Do same with last <number> posts from your profile
        #{Paint['like', :green]}                       Do same with your last like
        #{Paint['<number> likes', :green]}             Do same with your last <number> likes
        #{Paint['url', :magenta]}                        Do same with track from entered url

      #{Paint['Extra options:', :yellow]}
        #{Paint['from PERMALINK', :green]}             Do aforecited operations from custom user profile
        #{Paint['to PATH_TO_DIRECTORY', :green]}       Do aforecited operations to custom directory
        #{Paint['to current', :green]}                 Do aforecited operations to current working directory
        #{Paint['playlist ITUNES_PLAYLIST', :green]}   Do aforecited operations to custom iTunes playlist
    DL
  end

  def get
    puts <<-GET.gsub(/^ {6}/, '')
      #{Paint['Input:', :yellow]} nehm get OPTIONS [from PERMALINK] [to PATH_TO_DIRECTORY] [playlist ITUNES_PLAYLIST]

      #{Paint['Summary:', :yellow]}
        Downloading tracks, setting tags and adding to your iTunes library tracks from Soundcloud

      #{Paint['OPTIONS:', :yellow]}
        #{Paint['post', :green]}                       Do same with last post (track or repost) from your profile
        #{Paint['<number> posts', :green]}             Do same with last <number> posts from your profile
        #{Paint['like', :green]}                       Do same with your last like
        #{Paint['<number> likes', :green]}             Do same with your last <number> likes
        #{Paint['url', :magenta]}                        Do same with track from entered url

      #{Paint['Extra options:', :yellow]}
        #{Paint['from PERMALINK', :green]}             Do aforecited operations from profile with PERMALINK
        #{Paint['to PATH_TO_DIRECTORY', :green]}       Do aforecited operations to custom directory
        #{Paint['to current', :green]}                 Do aforecited operations to current working directory
        #{Paint['playlist ITUNES_PLAYLIST', :green]}   Do aforecited operations to custom iTunes playlist
    GET
  end

  def permalink
    puts <<-PERM.gsub(/^ {6}/, '')
      Permalink is the last word in your profile url
      Example: for profile url #{Paint['soundcloud.com/qwerty', :magenta]} permalink is #{Paint['qwerty', :magenta]}
    PERM
  end
end
