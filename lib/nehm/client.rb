require 'certifi'
require 'soundcloud'

module Nehm
  # Soundcloud API client.
  module Client
    # Set a SSL certificate file path for SC API
    ENV['SSL_CERT_FILE'] = Certifi.where

    # SoundCloud API client ID
    CLIENT_ID = '11a37feb6ccc034d5975f3f803928a32'

    # SoundCloud client object
    SC_CLIENT = Soundcloud.new(client_id: CLIENT_ID)

    def self.get(*args)
      SC_CLIENT.get(*args)
    end
  end
end
