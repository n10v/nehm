require 'taglib'

module Nehm
  # Get module responds to 'nehm get/dl ...' commands
  module Get
    def self.[](get_or_dl, args)
      # Processing arguments
      options = [{ name: 'to', method: PathManager.method(:temp_dl_path=) },
                 { name: 'from', method: UserManager.method(:temp_user=) },
                 { name: 'playlist', method: PlaylistManager.method(:temp_playlist=) }]

      options.each do |option|
        if args.include? option[:name]
          index = args.index(option[:name])
          value = args[index + 1]
          args.delete_at(index + 1)
          args.delete_at(index)

          option[:method].call(value)
        end
      end

      puts 'Getting information about track(s)'
      user = UserManager.user
      tracks = []
      tracks +=
        case args.last
        when 'like'
          Client.tracks(1, :likes, user.id)
        when 'post'
          Client.tracks(1, :posts, user.id)
        when 'likes'
          count = args[-2].to_i
          Client.tracks(count, :likes, user.id)
        when 'posts'
          count = args[-2].to_i
          Client.tracks(count, :posts, user.id)
        when %r{https:\/\/soundcloud.com\/}
          track(args.last)
        when nil
          puts 'You must provide option'.red
          puts "Input #{'nehm help'.yellow} for help"
          exit
        else
          puts "Invalid argument(s) '#{args.last}'".red
          puts "Input #{'nehm help'.yellow} for help"
          exit
        end

      itunes_playlist_ready = PlaylistManager.playlist && get_or_dl == :get && !OS.linux?
      tracks.each do |track|
        if track.streamable? && !track.nil?
          puts "\n"
          dl(track)
          dl(track.artwork)
          tag(track)
          track.artwork.suicide
          PlaylistManager.playlist.add_track(track.file_path) if itunes_playlist_ready
          puts "\n"
        else
          puts "#{'Track'.yellow} #{track.name.cyan} #{'undownloadable'.yellow}"
        end
      end
      puts 'Done!'.green
    end

    module_function

    def dl(arg)
      puts 'Downloading ' + arg.name
      path = arg.file_path
      url = arg.url
      command = "curl -# -o \"#{path}\" -L #{url}"
      `#{command}`
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

    def track(url)
      hash = Client.track(url)
      [*Track.new(hash)]
    end
  end
end
