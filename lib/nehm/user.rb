require 'json'
require 'faraday'
require 'paint'
require_relative 'client.rb'
require_relative 'config.rb'
require_relative 'user_control.rb'

class User
  def initialize(permalink = nil)
    client = Client.new
    @id =
      unless permalink.nil?
        user = client.get('/resolve', url: "https://soundcloud.com/#{permalink}")
        user.id
      else
        UserControl.default_id
      end
  end

  def likes(count)
    unless count.class == Fixnum
      puts Paint['Invalid number of likes!', :red]
      exit
    end

    client = Client.new
    likes = client.get("/users/#{@id}/favorites?limit=#{count}")
    likes.map { |like| Track.new(like) }
  end

  # Post is last track or repost in profile
  def posts(count)
    unless count.class == Fixnum
      puts Paint['Invalid number of posts!', :red]
      exit
    end

    conn = Faraday.new(url: 'https://api-v2.soundcloud.com/') do |faraday|
      faraday.request :url_encoded             # form-encode POST params
      faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
    end

    response = conn.get("/profile/soundcloud:users:#{@id}?limit=#{count}&offset=0")

    parsed = JSON.parse(response.body)
    parsed = parsed['collection']
    parsed.map { |track| Track.new(track['track']) }
  end
end
