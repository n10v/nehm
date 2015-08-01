require 'json'
require 'faraday'

class User
  def initialize(id)
    @id = id
  end

  def likes(count)
    # Method to_i return 0, when there aren't any numbers in string
    if count == 0
      puts Paint['Invalid number of likes!', :red]
      exit
    end

    likes = Client.get("/users/#{@id}/favorites?limit=#{count}")
    likes.map { |hash| Track.new(hash) }
  end

  # Post is last track/repost in profile
  def posts(count)
    # Method to_i return 0, when there aren't any numbers in string
    if count == 0
      puts Paint['Invalid number of posts!', :red]
      exit
    end

    # Official SC API wrapper doesn't support for posts
    # So I should get posts by HTTP requests
    conn = Faraday.new(url: 'https://api-v2.soundcloud.com/')
    response = conn.get("/profile/soundcloud:users:#{@id}?limit=#{count}&offset=0")

    parsed = JSON.parse(response.body)
    parsed = parsed['collection']
    parsed.map { |hash| Track.new(hash['track']) }
  end
end
