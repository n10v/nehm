class Track
  attr_reader :hash

  def initialize(hash)
    @hash = hash
  end

  def artist
    if @hash['title'].include?('-')
      title = @hash['title'].split('-')
      title[0].rstrip
    else
      @hash['user']['username']
    end
  end

  def artwork
    Artwork.new(self)
  end

  def dl_url
    "#{@hash['stream_url']}?client_id=#{Client::CLIENT_ID}"
  end

  def dl_name
    artist + ' - ' + title
  end

  def file_name
    "#{artist} - #{title}.mp3".tr('/', '')
  end

  def file_path
    File.join(PathControl.dl_path, file_name)
  end

  def id
    @hash['id'].to_s
  end

  def title
    if @hash['title'].include?('-')
      title = @hash['title'].split('-')
      title[1].lstrip
    else
      @hash['title']
    end
  end

end
