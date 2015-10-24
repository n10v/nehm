module Nehm

  ##
  # Write here description for command

  class SelectCommand < Command

    DEFAULT_LIMIT = 10

    DEFAULT_OFFSET = 0

    def initialize
      super
    end

    def execute
      @queue = []
      type = @options[:args].shift
      track_manager = TrackManager.new(@options)
      limit = options[:limit] ? options[:limit].to_i : DEFAULT_LIMIT
      offset = options[:offset] ? options[:offset].to_i : DEFAULT_OFFSET

      loop do

        tracks =
          case type
          when /l/
            track_manager.likes(limit, offset)
          when /p/
            track_manager.posts(limit, offset)
          end

        UI.menu do |menu|
          menu.header = 'Select track to add it to download queue'.green
          menu.prompt = 'Enter option:'.yellow

          tracks.each do |track|
            menu.choice(track.full_name) { add_track_to_queue(track) }
          end

          menu.choice('Download tracks from queue') { download_tracks_from_queue}
          menu.choice('View added tracks') { view_queue }
          menu.choice('Next Page') { offset += limit }
          menu.choice('Prev Page') { offset -= limit }
          menu.choice('Exit') { raise Interrupt }
        end

      end
    end

    def arguments
     { 'likes' => 'Select likes',
       'posts' => 'Select posts' }
    end

    def program_name
      'nehm select'
    end

    def summary
    end

    def usage
    end

  end
end
