require 'soundcloud'
require_relative 'config.rb'

module Client
  # SSL Certificate
  ENV['SSL_CERT_FILE'] = File.join(__dir__, 'cacert.pem')

  CLIENT_ID = '11a37feb6ccc034d5975f3f803928a32'

  def self.new
    @client ||= Soundcloud.new(client_id: CLIENT_ID)
  end
end
