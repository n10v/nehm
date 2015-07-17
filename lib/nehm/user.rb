require 'json'
require 'faraday'
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
    client = Client.new
    likes = client.get("/users/#{@id}/favorites?limit=#{count}")
    likes.map { |like| Track.new(like) }
  end

  def posts(count)
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
