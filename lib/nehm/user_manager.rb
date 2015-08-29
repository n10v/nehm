module UserManager
  def self.user
    @temp_user || default_user
  end

  def self.logged_in?
    Cfg.key?(:default_id)
  end

  def self.log_in
    loop do
      permalink = HighLine.new.ask('Please enter your permalink (last word in your profile url): ')
      user = get_user(permalink)
      if user
        Cfg[:default_id] = user.id
        Cfg[:permalink] = permalink
        puts Paint['Successfully logged in!', :green]
        break
      else
        puts Paint['Invalid permalink. Please enter correct permalink', :red]
      end
    end
  end

  def self.temp_user=(permalink)
    user = get_user(permalink)
    if user
      @temp_user = User.new(user.id)
    else
      puts Paint['Invalid permalink. Please enter correct permalink', :red]
      exit
    end
  end

  module_function

  def default_user
    if UserManager.logged_in?
      User.new(Cfg[:default_id])
    else
      puts Paint["You didn't logged in", :red]
      puts "Login from #{Paint['nehm configure', :yellow]} or use #{Paint['[from PERMALINK]', :yellow]} option"
      exit
    end
  end

  def get_user(permalink)
    begin
      user = Client.get('/resolve', url: "https://soundcloud.com/#{permalink}")
    rescue SoundCloud::ResponseError => e
      if e.message =~ /404/
        user = nil
      else
        raise e
      end
    end
    user
  end
end
