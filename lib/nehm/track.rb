module Nehm
  class Track

    attr_reader :hash

    def initialize(hash)
      @hash = hash
    end

    def artist
      name[0]
    end

    def artwork
      Artwork.new(self)
    end

    def file_name
      "#{full_name.tr(',./\\\'$%"', '')}.mp3"
    end

    def file_path
      File.join(ENV['dl_path'], file_name)
    end

    def full_name
      "#{artist} - #{title}"
    end

    def id
      @hash['id']
    end

    # Returns artist and title in array
    def name
      title = @hash['title']
      separators = [' - ', ' ~ ']
      separators.each do |sep|
        return title.split(sep) if title.include? sep
      end

      [@hash['user']['username'], title]
    end

    def title
      name[1]
    end

    def url
      "#{@hash['stream_url']}?client_id=#{Client::CLIENT_ID}"
    end

    def year
      @hash['created_at'][0..3].to_i
    end

  end
end
