module Nehm
  module UserManager
    def self.default_id
      Cfg[:default_id]
    end

    def self.get_id(permalink)
      user = Client.user(permalink)
      UI.term 'Invalid permalink. Please enter correct permalink' if user.nil?

      user['id']
    end

    def self.set_uid
      loop do
        permalink = HighLine.new.ask('Please enter your permalink (last word in your profile url): ')
        user = Client.user(permalink)
        if user
          Cfg[:default_id] = user.id
          Cfg[:permalink] = permalink
          UI.success 'Successfully logged in!'
          break
        else
          UI.error 'Invalid permalink. Please enter correct permalink'
        end
      end
    end

  end
end
