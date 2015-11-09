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
    # HTTP client object

    HTTP_CLIENT = HTTPClient.new

    ##
    # Max limit of tracks for correct SoundCloud requests

    TRACKS_LIMIT = 200

    ##
    # Returns raw array of likes or posts (depends on argument 'type')

    def self.tracks(count, offset, type, uid)
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
            likes(limit, i * TRACKS_LIMIT + offset, uid)
          when :posts
            posts(limit, i * TRACKS_LIMIT + offset, uid)
          end
      end
      tracks
    end

    def self.search(query)
      uri = "/tracks?q=#{query}"
      HTTP_CLIENT.get(1, uri)
    end

    ##
    # Returns track hash from SoundCloud by specified uri

    def self.track(uri)
      HTTP_CLIENT.resolve(uri)
    end

    ##
    # Returns user hash from SoundCloud or nil if user doesn't exist

    def self.user(permalink)
      url = "http://soundcloud.com/#{permalink}"
      begin
        HTTP_CLIENT.resolve(url)
      rescue HTTPClient::Status404
        return nil
      rescue HTTPClient::ConnectionError
        UI.term "Connection error. Check your internet connection\nSoundCloud can also be down"
      end
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
