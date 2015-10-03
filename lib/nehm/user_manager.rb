module Nehm
  module UserManager
    def self.default_id
      Cfg[:default_id]
    end

    def self.get_id(permalink)
      user = Client.user(permalink)
      abort "Invalid permalink. Please enter correct permalink\n".red if user.nil?

      user['id']
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
  end
end
