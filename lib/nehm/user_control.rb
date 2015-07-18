require 'highline'
require 'paint'
require_relative 'config.rb'
require_relative 'client.rb'

module UserControl
  def self.default_id
    if UserControl.logged_in?
      Config[:default_id]
    else
      puts Paint["You didn't logged in", :red]
      puts "Input #{Paint['nehm configure', :yellow]} to login"
      exit
    end
  end

  def self.user_exist?(url)
    Client.new.get('/resolve', url: url)
    rescue SoundCloud::ResponseError => e
      if e.message =~ /404/
        raise e
      else
        false
      end
    else
      true
  end

  def self.logged_in?
    Config.key?(:default_id)
  end

  def self.log_in
    loop do
      permalink = HighLine.new.ask('Please enter your permalink (last word in your profile url): ')
      client = Client.new
      url = "https://soundcloud.com/#{permalink}"
      if UserControl.user_exist?(url)
        user = client.get('/resolve', url: url)
        Config[:default_id] = user.id
        Config[:permalink] = permalink
        puts Paint['Successfully logged in!', :green]
        break
      else
        puts Paint['Invalid permalink. Please enter correct permalink', :red]
      end
    end
  end
end
