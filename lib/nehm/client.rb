require 'certifi'
require 'faraday'
require 'json'
require 'soundcloud'

module Nehm
  # Client module contains all SC API interaction
  module Client
    # Set a SSL certificate file path for SC API
    ENV['SSL_CERT_FILE'] = Certifi.where

    # SoundCloud API client ID
    CLIENT_ID = '11a37feb6ccc034d5975f3f803928a32'

    # SoundCloud client object
    SC_CLIENT = Soundcloud.new(client_id: CLIENT_ID)

    # Max limit of tracks for correct SoundCloud requests
    TRACKS_LIMIT = 200

    def self.tracks(count, type, user_id)
      abort "Invalid number of #{type}".red if count == 0

      iterations = count.to_f / TRACKS_LIMIT
      iterations = iterations.ceil

      tracks = []
      iterations.times do |i|
        limit = count < TRACKS_LIMIT ? count : TRACKS_LIMIT
        count -= TRACKS_LIMIT

        rejected = []
        tracks +=
          case type
          when 'likes'
            likes = likes(user_id, limit, i * TRACKS_LIMIT)
            likes.map! { |hash| Track.new(hash) }
          when 'posts'
            posts = posts(user_id, limit, i * TRACKS_LIMIT)
            rejected += tracks.reject! { |hash| hash['type'] == 'playlist' }
            posts.map! { |hash| Track.new(hash['track']) }
          end
      end

      abort "There are no #{type} yet".red if tracks.empty?

      puts "Was skipped #{rejected.length} playlist(s) (nehm doesn't download playlists)".yellow unless rejected.empty?

      tracks
    end

    def self.user(permalink)
      begin
        user = SC_CLIENT.get('/resolve', url: "https://soundcloud.com/#{permalink}")

      rescue SoundCloud::ResponseError => e
        return nil if e.message =~ /404/
      end

      user
    end

    module_function

    def likes(user_id, limit, offset)
      SC_CLIENT.get("/users/#{user_id}/favorites?limit=#{limit}&offset=#{offset}")
    end

    def posts
      conn = Faraday.new(url: 'https://api-v2.soundcloud.com/')
      response = conn.get("/profile/soundcloud:users:#{user_id}?limit=#{limit}&offset=#{offset}")
      parsed = JSON.parse(response.body)
      parsed['collection']
    end
  end
end
