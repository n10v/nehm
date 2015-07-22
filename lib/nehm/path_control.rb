require 'highline'
require 'paint'
require_relative 'config.rb'
class PathControl
  def self.dl_path
    @@temp_dl_path ? @@temp_dl_path : Config[:dl_path]
  end

  def self.temp_dl_path=(path)
    if Dir.exist?(path)
      @@temp_dl_path = path
    else
      puts Paint['Invalid path!', :red]
      exit
    end
  end

  def self.set_dl_path
    loop do
      default_path = File.join(ENV['HOME'], '/Music')
      path = HighLine.new.ask("Enter a FULL path to default download directory (press enter to set it to #{default_path}): ")
      path = default_path if path == ''

      if Dir.exist?(path)
        Config[:dl_path] = path
        puts Paint['Download directory set up!', :green]
        break
      else
        puts "\n"
        puts Paint["This directory doesn't exist. Please enter path again", :red]
      end
    end
  end

  def self.itunes_path
    Config[:itunes_path]
  end

  def self.set_itunes_path
    loop do
      default_path = File.join(ENV['HOME'], '/Music/iTunes')
      path = HighLine.new.ask("Enter a FULL path to iTunes directory (press enter to set it to #{default_path}): ")
      path = default_path if path == ''

      path = File.join(path, "iTunes\ Media/Automatically\ Add\ to\ iTunes.localized")

      if Dir.exist?(path)
        Config[:itunes_path] = path
        puts Paint['iTunes directory set up!', :green]
        break
      else
        puts "\n"
        puts Paint["This directory doesn't exist. Please enter path again", :red]
      end

    end
  end
end
