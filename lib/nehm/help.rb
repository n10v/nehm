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
    puts Paint['Available options:', :yellow]
    puts '  No options'
  end

  def dl
    puts Paint['Input: ', :yellow] + 'nehm dl OPTIONS [from PERMALINK]'
    puts "\n"
    puts Paint['OPTIONS:', :yellow]
    puts '  ' + Paint['post', :green]            + ' - Downloading and setting tags last post(track or repost) from your profile'
    puts '  ' + Paint['<number> posts', :green]  + ' - Downloading and setting tags last <number> posts from your profile'
    puts '  ' + Paint['like', :green]            + ' - Downloading and setting tags your last like'
    puts '  ' + Paint['<number> likes', :green]  + ' - Downloading and setting tags your last <number> likes'
    puts "\n"
    puts Paint['Extra options:', :yellow]
    puts '  ' + Paint['from PERMALINK', :green]     + ' - Do the aforecited operations from the custom user profile'
    puts '  ' + Paint['to PATHTODIRECTORY', :green] + ' - Do the aforecited operations to the custom directory'
  end

  def get
    puts Paint['Input: ', :yellow] + 'nehm get OPTIONS [from PERMALINK]'
    puts "\n"
    puts Paint['OPTIONS:', :yellow]
    puts '  ' + Paint['post', :green]            + ' - Downloading, setting tags and adding to your iTunes library last post(track or repost) from your profile'
    puts '  ' + Paint['<number> posts', :green]  + ' - Downloading, setting tags and adding to your iTunes library last <number> posts from your profile'
    puts '  ' + Paint['like', :green]            + ' - Downloading, setting tags and adding to your iTunes library your last like'
    puts '  ' + Paint['<number> likes', :green]  + ' - Downloading, setting tags and adding to your iTunes library your last <number> likes'
    puts "\n"
    puts Paint['Extra options:', :yellow]
    puts '  ' + Paint['from PERMALINK', :green]     + ' - Do the aforecited operations from the profile with PERMALINK'
    puts '  ' + Paint['to PATHTODIRECTORY', :green] + ' - Do the aforecited operations to the custom directory'
  end

  def permalink
    puts 'Permalink is the last word in your profile url'
    puts 'Example: for profile url ' + Paint['soundcloud.com/qwerty', :magenta] + ' permalink is ' + Paint['qwerty', :magenta]
  end
end
