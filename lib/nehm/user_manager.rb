module Nehm
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
        user = Client.user(permalink)
        if user
          Cfg[:default_id] = user.id
          Cfg[:permalink] = permalink
          puts 'Successfully logged in!'.green
          break
        else
          puts "Invalid permalink. Please enter correct permalink\n".red
        end
      end
    end

    def self.temp_user=(permalink)
      user = get_user(permalink)
      if user
        @temp_user = User.new(user.id)
      else
        puts 'Invalid permalink. Please enter correct permalink'.red
        exit
      end
    end

    module_function

    def default_user
      if UserManager.logged_in?
        User.new(Cfg[:default_id])
      else
        puts "You didn't logged in".red
        puts "Login from #{'nehm configure'.yellow} or use #{'[from PERMALINK]'.yellow} option"
        exit
      end
    end
  end
end
