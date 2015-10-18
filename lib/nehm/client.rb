require 'certifi'
require 'json'
require 'net/http'
require 'soundcloud'

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
    # SoundCloud client object

    SC_CLIENT = Soundcloud.new(client_id: CLIENT_ID)

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
      begin
        SC_CLIENT.get('/resolve', url: "https://soundcloud.com/#{permalink}")
      rescue SoundCloud::ResponseError => e
        return nil if e.message =~ /404/
      end
    end

    ##
    # Returns track hash from SoundCloud by specified url

    def self.track(url)
      SC_CLIENT.get('/resolve', url: url)
    end

    module_function

    def likes(limit, offset, uid)
      SC_CLIENT.get("/users/#{uid}/favorites?limit=#{limit}&offset=#{offset}")
    end

    ##
    # Stantard SoundCloud Ruby wrapper doesn't support reposts if user
    # isn't authorized
    # But api-v2.soundcloud.com supports it

    def posts(limit, offset, uid)
      uri = URI("https://api-v2.soundcloud.com/profile/soundcloud:users:#{uid}?limit=#{limit}&offset=#{offset}")
      response = Net::HTTP.get_response(uri)
      parsed = JSON.parse(response.body)
      parsed['collection']
    end

  end
end
