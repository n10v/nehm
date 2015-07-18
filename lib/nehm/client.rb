require 'soundcloud'
require_relative 'config.rb'

# Just a Soundcloud API client.
module Client
  # Set a SSL certificate file path for SC API
  ENV['SSL_CERT_FILE'] = File.join(__dir__, 'cacert.pem')

  CLIENT_ID = '11a37feb6ccc034d5975f3f803928a32'

  def self.new
    @client ||= Soundcloud.new(client_id: CLIENT_ID)
  end
end
