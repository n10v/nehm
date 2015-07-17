require 'taglib'
require 'fileutils'
require 'paint'
require_relative 'path_control.rb'
require_relative 'client.rb'
require_relative 'user.rb'
require_relative 'track.rb'

module TrackUtils
  # Public

  def self.get(dl, args)
    tracks = []
    tracks +=
      case args.last
      when 'like'
        User.new.likes(1)
      when 'post'
        User.new.posts(1)
      when 'likes'
        count = args[-2].to_i
        User.new.likes(count)
      when 'posts'
        count = args[-2].to_i
        User.new.posts(count)
      when %r{https:\/\/soundcloud.com\/}
        track_from_url(args.last)
      else
        puts Paint['Invalid argument(s)', :red]
        puts "Input #{Paint['nehm help', :yellow]} for help"
        exit
      end

    tracks.each do |track|
      dl(track)
      tag(track)
      cp(track) unless (dl == :dl) || (linux?)
      track.artwork.suicide
    end
    puts Paint['Done!', :green]
  end

  # Private

  module_function

  def track_from_url(url)
    client = Client.new
    track = client.get('/resolve', url: url)
    tracks = []
    tracks << Track.new(track)
  end

  def dl(track)
    # Downloading track and artwork
    puts 'Downloading ' + track.artist + ' - ' + track.title
    path = track.file_path
    dl_url = track.dl_url
    command = "curl -# -o '" + path + "' -L " + dl_url
    system(command)

    puts 'Downloading artwork'
    artwork = track.artwork
    path = artwork.file_path
    dl_url = artwork.dl_url
    command = "curl -# -o '" + path + "' -L " + dl_url
    system(command)
  end

  def tag(track)
    path = track.file_path
    TagLib::MPEG::File.open(path) do |file|
      puts 'Setting tags'
      #TODO: Add more tags (year)
      tag = file.id3v2_tag
      tag.artist = track.artist
      tag.title = track.title

      # Adding artwork
      apic = TagLib::ID3v2::AttachedPictureFrame.new
      apic.mime_type = 'image/jpeg'
      apic.description = 'Cover'
      apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
      apic.picture = File.open(track.artwork.file_path, 'rb') { |f| f.read }
      tag.add_frame(apic)

      file.save
    end
  end

  def cp(track)
    puts 'Adding to iTunes library'
    FileUtils.cp(track.file_path, PathControl.itunes_path)
  end
end
