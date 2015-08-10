# Help module responds to 'nehm help ...' command
module Help
  def self.available_commands
    puts Paint['Avalaible nehm commands:', :yellow]
    puts '  ' + Paint['get', :green]       + ' - Downloading, setting tags and adding to your iTunes library last post or like from your profile'
    puts '  ' + Paint['dl', :green]        + ' - Downloading and setting tags last post or like from your profile'
    puts '  ' + Paint['configure', :green] + ' - Configuring application'
    puts "See #{Paint['nehm help [command]', :yellow]} to read about a specific subcommand"
  end

  def self.show(command)
    case command
    when 'get', 'dl', 'configure'
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
    puts Paint['Input: ', :yellow] + 'nehm configure'
    puts "\n"
    puts Paint['Summary:', :yellow]
    puts '  Configuring nehm app'
  end

  def dl
    puts Paint['Input: ', :yellow] + 'nehm dl OPTIONS [from PERMALINK] [to PATH_TO_DIRECTORY] [playlist ITUNES_PLAYLIST]'
    puts "\n"
    puts Paint['Summary:', :yellow]
    puts '  Downloading tracks from SoundCloud and setting tags'
    puts "\n"
    puts Paint['OPTIONS:', :yellow]
    puts '  ' + Paint['post', :green] + '                       Do same with last post (track or repost) from your profile'
    puts '  ' + Paint['<number> posts', :green] + '             Do same with last <number> posts from your profile'
    puts '  ' + Paint['like', :green] + '                       Do same with tags your last like'
    puts '  ' + Paint['<number> likes', :green] + '             Do same with tags your last <number> likes'
    puts "\n"
    puts Paint['Extra options:', :yellow]
    puts '  ' + Paint['from PERMALINK', :green] + '             Do aforecited operations from custom user profile'
    puts '  ' + Paint['to PATH_TO_DIRECTORY', :green] + '       Do aforecited operations to custom directory'
    puts '  ' + Paint['to current', :green] + '                 Do aforecited operations to current working directory'
    puts '  ' + Paint['playlist ITUNES_PLAYLIST', :green] + '   Do aforecited operations to custom iTunes playlist'
  end

  def get
    puts Paint['Input: ', :yellow] + 'nehm get OPTIONS [from PERMALINK] [to PATH_TO_DIRECTORY] [playlist ITUNES_PLAYLIST]'
    puts "\n"
    puts Paint['Summary:', :yellow]
    puts '  Downloading tracks, setting tags and adding to your iTunes library tracks from Soundcloud'
    puts "\n"
    puts Paint['OPTIONS:', :yellow]
    puts '  ' + Paint['post', :green] + '                       Do same with last post (track or repost) from your profile'
    puts '  ' + Paint['<number> posts', :green] + '             Do same with last <number> posts from your profile'
    puts '  ' + Paint['like', :green] + '                       Do same with your last like'
    puts '  ' + Paint['<number> likes', :green] + '             Do same with your last <number> likes'
    puts "\n"
    puts Paint['Extra options:', :yellow]
    puts '  ' + Paint['from PERMALINK', :green] + '             Do aforecited operations from profile with PERMALINK'
    puts '  ' + Paint['to PATH_TO_DIRECTORY', :green] + '       Do aforecited operations to custom directory'
    puts '  ' + Paint['to current', :green] + '                 Do aforecited operations to current working directory'
    puts '  ' + Paint['playlist ITUNES_PLAYLIST', :green] + '   Do aforecited operations to custom iTunes playlist'
  end

  def permalink
    puts 'Permalink is the last word in your profile url'
    puts 'Example: for profile url ' + Paint['soundcloud.com/qwerty', :magenta] + ' permalink is ' + Paint['qwerty', :magenta]
  end
end
