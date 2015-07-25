require 'json'
require 'faraday'

class User
  def initialize(id)
    @id = id
  end

  def likes(count)
    unless count.class == Fixnum
      puts Paint['Invalid number of likes!', :red]
      exit
    end

    likes = Client.get("/users/#{@id}/favorites?limit=#{count}")
    likes.map { |hash| Track.new(hash) }
  end

  # Post is last track or repost in profile
  def posts(count)
    unless count.class == Fixnum
      puts Paint['Invalid number of posts!', :red]
      exit
    end

    conn = Faraday.new(url: 'https://api-v2.soundcloud.com/')
    response = conn.get("/profile/soundcloud:users:#{@id}?limit=#{count}&offset=0")

    parsed = JSON.parse(response.body)
    parsed = parsed['collection']
    parsed.map { |hash| Track.new(hash['track']) }
  end
end
