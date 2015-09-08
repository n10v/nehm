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

  def file_name
    "#{name}.mp3".tr("/'\"", '')
  end

  def file_path
    File.join(PathManager.dl_path, file_name)
  end

  def id
    @hash['id'].to_s
  end

  # Use in Get.dl and in Track.file_name
  def name
    artist + ' - ' + title
  end

  def streamable?
    @hash['streamable'] ? true : false
  end

  def title
    if @hash['title'].include?('-')
      title = @hash['title'].split('-')
      title[1].lstrip
    else
      @hash['title']
    end
  end

  def url
    "#{@hash['stream_url']}?client_id=#{Client::CLIENT_ID}"
  end

  def year
    @hash['created_at'][0..3].to_i
  end
end
