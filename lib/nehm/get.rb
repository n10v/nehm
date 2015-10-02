require 'taglib'

module Nehm
  # Get module responds to 'nehm get/dl ...' commands
  module Get
    def self.[](type, args)
      # Processing arguments
      # options = [{ name: 'to', method: PathManager.method(:temp_dl_path=) },
      #            { name: 'from', method: UserManager.method(:temp_user=) },
      #            { name: 'playlist', method: PlaylistManager.method(:temp_playlist=) }]
      #
      # options.each do |option|
      #   if args.include? option[:name]
      #     index = args.index(option[:name])
      #     value = args[index + 1]
      #     args.delete_at(index + 1)
      #     args.delete_at(index)
      #
      #     option[:method].call(value)
      #   end
      # end

      puts 'Getting information about track(s)'
      uid = UserManager.default_id
      tracks = []
      tracks +=
        case args.last
        when 'like'
          likes(1, uid)
        when 'post'
          posts(1, uid)
        when 'likes'
          count = args[-2].to_i
          likes(count, uid)
        when 'posts'
          count = args[-2].to_i
          posts(count, uid)
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

      itunes_playlist_ready = PlaylistManager.playlist && type == :get && !OS.linux?
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

    def likes(count, uid)
      likes = Client.tracks(count, :likes, uid)
      abort 'There are no likes yet'.red if likes.empty?

      likes.map! { |hash| Track.new(hash) }
    end

    def posts(count, uid)
      posts = Client.tracks(count, :posts, uid)
      abort 'There are no posts yet'.red if posts.empty?

      # Removing playlists
      rejected_count = 0
      rejected = posts.reject! { |hash| hash['type'] == 'playlist' }
      rejected_count = rejected.length if rejected
      puts "Was skipped #{rejected_count} playlist(s) (nehm doesn't download playlists)".yellow if rejected_count > 0

      posts.map! { |hash| Track.new(hash['track']) }
    end

    def track(url)
      hash = Client.track(url)
      [*Track.new(hash)]
    end
  end
end
