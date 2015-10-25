module Nehm

  ##
  # Write here description for command

  class SelectCommand < Command

    DEFAULT_LIMIT = 10

    DEFAULT_OFFSET = 0

    def initialize
      super

      add_option(:limit, 'limit NUMBER',
                'Show NUMBER tracks on each page')

      add_option(:offset, 'offset NUMBER',
                'Show from NUMBER track')
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

        UI.page_view do |page|
          page.header = 'Select track to add it to download queue'.green

          page.newline

          tracks.each do |track|
            page.choice(:inc, track.full_name) { add_track_to_queue(track) }
          end

          page.newline

          page.choice('d', 'Download tracks from queue'.green) { download_tracks_from_queue}
          page.choice('v', 'View added tracks'.green) { view_queue }
          page.choice('n', 'Next Page'.magenta) { offset += limit }
          page.choice('p', 'Prev Page'.magenta) { offset -= limit }
          page.choice('e', 'Exit'.red) { raise Interrupt }
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

    private

    def add_track_to_queue(track)
      @queue << track
      UI.success "Track #{track.full_name} added"
    end

    def download_tracks_from_queue
      track_manager = TrackManager.new
      track_manager.process_tracks(@queue)
    end

    def view_queue
      @queue.each do |track|
        puts track.full_name
      end
    end

  end
end
