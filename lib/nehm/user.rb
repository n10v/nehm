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
      # Method to_i return 0, if there aren't any numbers in string
      if count == 0
        puts 'Invalid number of likes!'.red
        exit
      end

      d = count / SOUNDCLOUD_MAX_LIMIT
      m = count % SOUNDCLOUD_MAX_LIMIT
      d = m == 0 ? d : d + 1

      likes = []
      d.times do |i|
        limit = count > SOUNDCLOUD_MAX_LIMIT ? SOUNDCLOUD_MAX_LIMIT : count
        count -= SOUNDCLOUD_MAX_LIMIT

        likes += Client.get("/users/#{@id}/favorites?limit=#{limit}&offset=#{(i)*SOUNDCLOUD_MAX_LIMIT}")
      end

      if likes.empty?
        puts 'There are no likes yet :('.red
        exit
      end

      likes.map! { |hash| Track.new(hash) }
    end

    # Post is last track/repost in profile
    def posts(count)
      # Method to_i return 0, if there aren't any numbers in string
      if count == 0
        puts 'Invalid number of posts!'.red
        exit
      end

      d = count / SOUNDCLOUD_MAX_LIMIT
      m = count % SOUNDCLOUD_MAX_LIMIT
      d = m == 0 ? d : d + 1

      # Official SC API wrapper doesn't support posts
      # So I should get posts by HTTP requests
      conn = Faraday.new(url: 'https://api-v2.soundcloud.com/')

      posts = []
      d.times do |i|
        limit = count > SOUNDCLOUD_MAX_LIMIT ? SOUNDCLOUD_MAX_LIMIT : count
        count -= SOUNDCLOUD_MAX_LIMIT

        response = conn.get("/profile/soundcloud:users:#{@id}?limit=#{limit}&offset=#{i*SOUNDCLOUD_MAX_LIMIT}")
        parsed = JSON.parse(response.body)
        collection = parsed['collection']

        break if collection.nil?

        posts += collection
      end

      if posts.empty?
        puts 'There are no posts yet :('.red
        exit
      end

      rejected = posts.reject! { |hash| hash['type'] == 'playlist' }
      puts "Was skipped #{rejected.length} playlist(s) (nehm doesn't download playlists)".yellow if rejected

      posts.map! { |hash| Track.new(hash['track']) }
    end
  end
end
