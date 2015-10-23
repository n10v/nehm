require 'certifi'
require 'nehm/http_client'

module Nehm

  ##
  # Client module contains all SC API interaction methods

  module Client

    ##
    # SSL certificate file path for SC API

    ENV['SSL_CERT_FILE'] = Certifi.where

    ##
    # SoundCloud API client ID

    CLIENT_ID = '11a37feb6ccc034d5975f3f803928a32'

    ##
    # HTTP client object

    HTTP_CLIENT = HTTPClient.new(client_id: CLIENT_ID)

    ##
    # Max limit of tracks for correct SoundCloud requests

    TRACKS_LIMIT = 200

    ##
    # Returns raw array of likes or posts (depends on argument 'type')

    def self.tracks(count, type, uid)
      UI.term "Invalid number of #{type}" if count == 0

      iterations = count.to_f / TRACKS_LIMIT
      iterations = iterations.ceil

      tracks = []
      iterations.times do |i|
        limit = count < TRACKS_LIMIT ? count : TRACKS_LIMIT
        count -= TRACKS_LIMIT

        tracks +=
          case type
          when :likes
            likes(limit, i * TRACKS_LIMIT, uid)
          when :posts
            posts(limit, i * TRACKS_LIMIT, uid)
          end
      end
      tracks
    end

    ##
    # Returns user hash from SoundCloud or nil if user doesn't exist

    def self.user(permalink)
      uri = "/resolve?uri=https://soundcloud.com/#{permalink}"
      begin
        HTTP_CLIENT.get(1, uri)
      rescue SoundCloud::ResponseError => e
        return nil if e.message =~ /404/
      end
    end

    ##
    # Returns track hash from SoundCloud by specified uri

    def self.track(uri)
      uri = "/resolve?url=#{uri}"
      HTTP_CLIENT.get(1, uri)
    end

    module_function

    def likes(limit, offset, uid)
      uri = "/users/#{uid}/favorites?limit=#{limit}&offset=#{offset}"
      HTTP_CLIENT.get(1, uri)
    end

    def posts(limit, offset, uid)
      uri = "/profile/soundcloud:users:#{uid}?limit=#{limit}&offset=#{offset}"
      response = HTTP_CLIENT.get(2, uri)
      response['collection']
    end

  end
end
