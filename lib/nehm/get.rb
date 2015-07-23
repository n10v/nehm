require 'taglib'
require 'fileutils'

# TrackUtils module responds to 'nehm get/dl ...' commands
module Get
  def self.get(get_or_dl, args)

    user =
      # If option 'from ...' typed
      if args.include? 'from'
        index = args.index('from')
        permalink = args[index + 1]

        args.delete_at(index + 1)
        args.delete_at(index)
        UserControl.user(permalink)
      else
        UserControl.default_user
      end

    # If option 'to ...' typed
    if args.include? 'to'
      index = args.index('to')
      path = args[index + 1]

      path = File.join(ENV['HOME'], path[1..-1]) if path[0] == '~'

      PathControl.temp_dl_path = path

      args.delete_at(index + 1)
      args.delete_at(index)
    end

    tracks = []
    tracks +=
      case args.last
      when 'like'
        user.likes(1)

      when 'post'
        user.posts(1)

      when 'likes'
        count = args[-2].to_i
        user.likes(count)

      when 'posts'
        count = args[-2].to_i
        user.posts(count)

      when %r{https:\/\/soundcloud.com\/}
        track_from_url(args.last)

      else
        puts Paint['Invalid argument(s)', :red]
        puts "Input #{Paint['nehm help', :yellow]} for help"
        exit
      end

    tracks.each do |track|
      dl(track)
      dl(track.artwork)
      tag(track)
      cp(track) unless (get_or_dl == :dl) || (OS.linux?)
      track.artwork.suicide
    end
    puts Paint['Done!', :green]
  end

  alias [] get

  module_function

  def track_from_url(url)
    client = Client.new
    track = client.get('/resolve', url: url)
    [*Track.new(track)]
  end

  def dl(arg)
    puts 'Downloading ' + arg.name
    path = arg.file_path
    url = arg.url
    command = "curl -# -o '" + path + "' -L " + url
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
