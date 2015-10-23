require 'json'
require 'net/http'

module Nehm

  class HTTPClient

    def initialize(client_id)
      @client_id = client_id
    end

    def get(api_version, uri_string)
      uri =
        case api_version
        when 1
          'http://api.soundcloud.com'
        when 2
          'https://api-v2.soundcloud.com'
        end
      uri += uri_string
      uri += "&client_id=#{@client_id}" if api_version == 1
      uri = URI(uri)

      response = Net::HTTP.get_response(uri)
      JSON.parse(response.body)
    end
  end
end
