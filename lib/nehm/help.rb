# Help module responds to 'nehm help ...' command
module Help

  # Public

  def self.available_commands
    puts Paint['Avalaible nehm commands:', :yellow]
    puts '  ' + Paint['get', :green]       + ' - Downloading, setting tags and adding to your iTunes library last post or like from your profile'
    puts '  ' + Paint['dl', :green]        + ' - Downloading and setting tags last post or like from your profile'
    puts '  ' + Paint['configure', :green] + ' - Configuring application'
    puts "See #{Paint['nehm help [command]']} to read about a specific subcommand"
  end

  def self.show(command)
    case command
    when 'get', 'dl', 'configure'
      Help.send(command)
    else
      Help.available_commands
    end
  end

  # Private

  module_function

  def configure
    puts Paint['Input: ', :yellow] + 'nehm configure'

    puts Paint['Available options:', :yellow]
    puts '  No options'
  end

  def dl
    puts Paint['Input: ', :yellow] + 'nehm dl OPTIONS'

    puts Paint['Available options:', :yellow]
    puts '  ' + Paint['track', :green]           + ' - Downloading and setting tags last post(track or repost) from your profile'
    puts '  ' + Paint['[number] tracks', :green] + ' - Downloading and setting tags last [number] posts from your profile'
    puts '  ' + Paint['like', :green]            + ' - Downloading and setting tags your last like'
    puts '  ' + Paint['[number] likes', :green]  + ' - Downloading and setting tags your last [number] likes'
  end

  def get
    puts Paint['Input: ', :yellow] + 'nehm get OPTIONS'

    puts Paint['Available options:', :yellow]
    puts '  ' + Paint['track', :green]           + ' - Downloading, setting tags and adding to your iTunes library last post(track or repost) from your profile'
    puts '  ' + Paint['[number] tracks', :green] + ' - Downloading, setting tags and adding to your iTunes library last [number] posts from your profile'
    puts '  ' + Paint['like', :green]            + ' - Downloading, setting tags and adding to your iTunes library your last like'
    puts '  ' + Paint['[number] likes', :green]  + ' - Downloading, setting tags and adding to your iTunes library your last [number] likes'
  end

  def permalink
    puts 'Permalink is the last word in your profile url'
    puts 'Example: for profile url ' + Paint['soundcloud.com/qwerty', :magenta] + ' permalink is ' + Paint['qwerty', :magenta]
  end

end
