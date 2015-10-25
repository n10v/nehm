module Nehm

  ##
  # User manager works with SoundCloud users' id

  module UserManager

    ##
    # Returns default user id (contains in ~/.nehmconfig)

    def self.default_uid
      Cfg[:default_id]
    end

    def self.get_uid(permalink)
      user = Client.user(permalink)
      UI.term 'Invalid permalink. Please enter correct permalink' if user.nil?

      user['id']
    end

    def self.set_uid
      loop do
        permalink = UI.ask('Please enter your permalink (last word in your profile url): ')
        user = Client.user(permalink)
        if user
          Cfg[:default_id] = user['id']
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
