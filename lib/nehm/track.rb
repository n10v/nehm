module Nehm
  class Track
    attr_reader :hash

    def initialize(hash)
      @hash = hash
    end

    def artist
      title = @hash['title']

      if title.include? ' - '
        title.split(' - ')[0]
      else
        @hash['user']['username']
      end
    end

    def artwork
      Artwork.new(self)
    end

    def file_name
      "#{name}.mp3".tr("/'\"", '')
    end

    def file_path
      File.join(PathManager.dl_path, file_name)
    end

    def id
      @hash['id']
    end

    # Used in Get#dl and in Track#file_name
    def name
      artist + ' - ' + title
    end

    def streamable?
      @hash['streamable']
    end

    def title
      title = @hash['title']

      if title.include? ' - '
        title.split(' - ')[1]
      else
        title
      end
    end

    def url
      "#{@hash['stream_url']}?client_id=#{Client::CLIENT_ID}"
    end

    def year
      @hash['created_at'][0..3].to_i
    end
  end
end
