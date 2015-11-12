module Nehm
  class TracksViewCommand < Command

    DEFAULT_LIMIT = 10

    DEFAULT_OFFSET = 0

    def initialize
      super
    end

    def execute
      setup_environment

      tracks = []
      old_offset = -1

      @queue = []
      @track_manager = TrackManager.new(@options)

      loop do
        # If offset changed
        unless old_offset == @offset
          tracks = get_tracks
          old_offset = @offset
        end

        # If tracks == nil, then there is a last page or there aren't tracks
        if tracks.nil?
          @msg = 'There are no more tracks'.red
          prev_page
          next
        end

        show_menu(tracks)
      end
    end

    protected

    def get_tracks; end

    def show_menu(tracks)
      UI.menu do |menu|
        menu.header = 'Enter the number of track to add it to download queue'.green

        menu.msg_bar = @msg

        tracks.each do |track|
          ids = @queue.map(&:id) # Get ids of tracks in queue
          if ids.include? track.id
            menu.choice(:added, track.full_name) { already_added(track) }
          else
            menu.choice(:inc, track.full_name) { add_track_to_queue(track) }
          end
        end

        menu.newline

        menu.choice('d', 'Download tracks from queue'.green.freeze) { download_tracks_from_queue; UI.term }
        menu.choice('n', 'Next page'.magenta.freeze) { next_page }
        menu.choice('p', 'Prev page'.magenta.freeze) { prev_page }
      end
    end

    def setup_environment
      limit = @options[:limit]
      @limit =
        if limit
          limit = limit.to_i
          UI.term "Invalid limit value\nIt should be more than 0" if limit <= 0
          limit
        else
          DEFAULT_LIMIT
        end
    end

    def add_track_to_queue(track)
      @queue << track
      @msg = "'#{track.full_name}' added".green
    end

    def already_added(track)
      @msg = "'#{track.full_name}' was already added".yellow
    end

    def download_tracks_from_queue
      @track_manager.process_tracks(@queue)
    end

    def next_page
      @offset += @limit
    end

    def prev_page
      @offset -= @limit if @offset >= @limit
    end

  end
end
