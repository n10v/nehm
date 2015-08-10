require 'taglib'
require 'fileutils'

# TrackUtils module responds to 'nehm get/dl ...' commands
module Get
  def self.[](get_or_dl, args)
    # Processing arguments
    options = [{ name: 'to', module: PathControl, setter: :temp_dl_path= },
               { name: 'from', module: UserControl, setter: :temp_user= },
               { name: 'playlist', module: PlaylistControl, setter: :temp_playlist= }]

    options.each do |option|
      if args.include? option[:name]
        index = args.index(option[:name])
        value = args[index + 1]
        args.delete_at(index + 1)
        args.delete_at(index)

        option[:module].send(option[:setter], value)
      end
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

    # Check if iTunes path set up
    if !PathControl.itunes_path && get_or_dl == :get && !OS.linux?
      puts Paint["You don't set up iTunes path!", :yellow]
      puts "Your track won't add to iTunes library"
      itunes_set_up = false
    else
      itunes_set_up = true
    end

    playlist = PlaylistControl.playlist

    tracks.each do |track|
      dl(track)
      dl(track.artwork)
      tag(track)
      if itunes_set_up && !OS.linux? && get_or_dl == :get
        cp(track)
        wait_while_itunes_add_track_to_lib(track) if playlist
        playlist.add_track(track.file_path) if playlist
      end

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

  # Check when iTunes will add track to its library from 'Auto' directory
  def wait_while_itunes_add_track_to_lib(track)
    loop do
      break unless File.exist?(File.join(PathControl.itunes_path, track.file_name))
    end
  end
end
