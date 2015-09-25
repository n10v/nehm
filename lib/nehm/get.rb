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
        when nil
          puts Paint['You must provide option', :red]
          puts "Input #{Paint['nehm help', :yellow]} for help"
          exit
        else
          puts Paint["Invalid argument(s) '#{args.last}'", :red]
          puts "Input #{Paint['nehm help', :yellow]} for help"
          exit
        end

      tracks.each do |track|
        if track.streamable?
          puts "\n"
          dl(track)
          dl(track.artwork)
          tag(track)
          track.artwork.suicide
          PlaylistManager.playlist.add_track(track.file_path) if PlaylistManager.playlist && get_or_dl == :get && !OS.linux?
          puts "\n"
        else
          puts "#{Paint['Track', :yellow]} #{Paint[track.name, :cyan]} #{Paint['undownloadable', :yellow]}"
        end
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
  end
end
