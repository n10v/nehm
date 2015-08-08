require 'taglib'
require 'fileutils'

# TrackUtils module responds to 'nehm get/dl ...' commands
module Get
  def self.[](get_or_dl, args)
    # If option 'playlist ...' entered
    if (args.include? 'playlist') && (!OS.linux)
      index = args.index('playlist')
      playlist = args[index + 1]
      args.delete_at(index + 1)
      args.delete_at(index)

      PlaylistControl.temp_playlist = playlist
    end

    # If option 'from ...' entered
    if args.include? 'from'
      index = args.index('from')
      permalink = args[index + 1]
      args.delete_at(index + 1)
      args.delete_at(index)

      UserControl.temp_user = permalink
    end

    # If option 'to ...' entered
    if args.include? 'to'
      index = args.index('to')
      path = args[index + 1]
      args.delete_at(index + 1)
      args.delete_at(index)

      # If 'to ~/../..' entered
      path = PathControl.tilde_to_home(path) if PathControl.tilde_at_top?(path)

      # If 'to current' entered
      path = Dir.pwd if path == 'current'

      PathControl.temp_dl_path = path
    end

    user = UserControl.user
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

    playlist = PlaylistControl.playlist

    tracks.each do |track|
      dl(track)
      dl(track.artwork)
      tag(track)
      cp(track) unless (get_or_dl == :dl) && (OS.linux?)
      playlist.add_track(track.file_path) if playlist && !OS.linux?
      track.artwork.suicide
    end
    puts Paint['Done!', :green]
  end

  module_function

  def track_from_url(url)
    hash = Client.get('/resolve', url: url)
    [*Track.new(hash)]
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
      tag = file.id3v2_tag
      tag.artist = track.artist
      tag.title = track.title
      tag.year = track.year

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
