# Artwork objects contains all needed information of track's artwork
class Artwork
  def initialize(track)
    @track = track
  end

  def dl_url
    hash = @track.hash
    if hash['artwork_url'].nil?
      hash['user']['avatar_url'].sub('large', 't500x500')
    else
      hash['artwork_url'].sub('large', 't500x500')
    end
  end

  # Use in Get.dl
  def name
    'artwork'
  end

  def file_path
    id = @track.id
    file_name = "#{id}.jpg"
    File.join('/tmp', file_name)
  end

  def suicide
    File.delete(file_path)
  end

end
