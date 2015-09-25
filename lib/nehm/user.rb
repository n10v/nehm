require 'json'
require 'faraday'

module Nehm
  class User
    # Max limit of tracks for correct SoundCloud requests
    SOUNDCLOUD_MAX_LIMIT = 180

    def initialize(id)
      @id = id
    end

    def likes(count)
      if count == 0
        puts 'Invalid number of likes!'.red
        exit
      end

      iterations = count.to_f / SOUNDCLOUD_MAX_LIMIT
      iterations = iterations.ceil

      likes = []
      iterations.times do |i|
        limit = count < SOUNDCLOUD_MAX_LIMIT ? count : SOUNDCLOUD_MAX_LIMIT
        count -= SOUNDCLOUD_MAX_LIMIT

        likes += Client.get("/users/#{@id}/favorites?limit=#{limit}&offset=#{i*SOUNDCLOUD_MAX_LIMIT}")
      end

      if likes.empty?
        puts 'There are no likes yet'.red
        exit
      end

      likes.map! { |hash| Track.new(hash) }
    end

    # Post is last track/repost in profile
    def posts(count)
      if count == 0
        puts 'Invalid number of posts!'.red
        exit
      end

      iterations = count.to_f / SOUNDCLOUD_MAX_LIMIT
      iterations = iterations.ceil

      # Official SC API wrapper doesn't support posts
      # So I should get posts by HTTP requests via undocumented V2 API
      conn = Faraday.new(url: 'https://api-v2.soundcloud.com/')

      posts = []
      iterations.times do |i|
        limit = count < SOUNDCLOUD_MAX_LIMIT ? count : SOUNDCLOUD_MAX_LIMIT
        count -= SOUNDCLOUD_MAX_LIMIT

        response = conn.get("/profile/soundcloud:users:#{@id}?limit=#{limit}&offset=#{i*SOUNDCLOUD_MAX_LIMIT}")
        parsed = JSON.parse(response.body)
        collection = parsed['collection']

        break if collection.nil?

        posts += collection
      end

      if posts.empty?
        puts 'There are no posts yet'.red
        exit
      end

      rejected = posts.reject! { |hash| hash['type'] == 'playlist' }
      puts "Was skipped #{rejected.length} playlist(s) (nehm doesn't download playlists)".yellow if rejected

      posts.map! { |hash| Track.new(hash['track']) }
    end
  end
end
