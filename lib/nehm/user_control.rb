module UserControl


  def self.logged_in?
    Config.key?(:default_id)
  end

  def self.log_in
    loop do
      permalink = HighLine.new.ask('Please enter your permalink (last word in your profile url): ')
      url = "https://soundcloud.com/#{permalink}"
      if user_exist?(permalink)
        user = Client.get('/resolve', url: url)
        Config[:default_id] = user.id
        Config[:permalink] = permalink
        puts Paint['Successfully logged in!', :green]
        break
      else
        puts Paint['Invalid permalink. Please enter correct permalink', :red]
      end
    end
  end

  def self.temp_user=(permalink)
    if user_exist?(permalink)
      user = Client.get('/resolve', url: "https://soundcloud.com/#{permalink}")
      @temp_user = User.new(user.id)
    else
      puts Paint['Invalid permalink. Please enter correct permalink', :red]
      exit
    end
  end

  def self.user
    @temp_user || default_user
  end

  module_function

  def default_user
    if UserControl.logged_in?
      User.new(Config[:default_id])
    else
      puts Paint["You didn't logged in", :red]
      puts "Input #{Paint['nehm configure', :yellow]} to login"
      exit
    end
  end

  def user_exist?(permalink)
    Client.get('/resolve', url: "https://soundcloud.com/#{permalink}")

    rescue SoundCloud::ResponseError => e
      if e.message =~ /404/
        false
      else
        raise e
      end
    else
      true
  end
end
