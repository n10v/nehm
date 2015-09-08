require 'json'
require 'faraday'

class User
  def initialize(id)
    @id = id
  end

  def likes(count)
    # Method to_i return 0, if there aren't any numbers in string
    if count == 0
      puts Paint['Invalid number of likes!', :red]
      exit
    end

    likes = []
    count.times do |i|
      likes += Client.get("/users/#{@id}/favorites?limit=1&offset=#{i}")
    end

    if likes.empty?
      puts Paint['There are no likes yet :(', :red]
      exit
    end

    likes.map { |hash| Track.new(hash) }
  end

  # Post is last track/repost in profile
  def posts(count_of_playlists_and_posts)
    # Method to_i return 0, if there aren't any numbers in string
    if count_of_playlists_and_posts == 0
      puts Paint['Invalid number of posts!', :red]
      exit
    end

    # Official SC API wrapper doesn't support posts
    # So I should get posts by HTTP requests
    conn = Faraday.new(url: 'https://api-v2.soundcloud.com/')

    posts = []
    only_posts = 0
    until only_posts == count_of_playlists_and_posts
      response = conn.get("/profile/soundcloud:users:#{@id}?limit=1&offset=#{only_posts}")
      parsed = JSON.parse(response.body)
      collection = parsed['collection'].first
      only_posts += 1

      if collection['type'] == 'playlist'
        count_of_playlists_and_posts += 1
        next
      end

      posts << collection
    end

    if posts.empty?
      puts Paint['There are no posts yet :(', :red]
      exit
    end

    posts.map { |hash| Track.new(hash['track']) }
  end
end
