module Nehm
  class TracksViewCommand < Command

    DEFAULT_LIMIT = 10

    DEFAULT_OFFSET = 0

    def initialize
      super
    end

    def execute
      setup_environment

      old_offset = @offset

      @queue = []
      @track_manager = TrackManager.new(@options)

      tracks = get_tracks
      UI.term 'There are no tracks yet' if tracks.nil?

      loop do
        # If offset changed, update list of tracks
        unless old_offset == @offset
          tracks = get_tracks
          old_offset = @offset
        end

        if tracks.nil?
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

        ids = @queue.map(&:id) # Get ids of tracks in queue
        tracks.each do |track|
          track_info = "#{track.full_name} | #{track.duration}"

          if ids.include? track.id
            menu.choice(:added, track_info)
          else
            menu.choice(:inc, track_info) { add_track_to_queue(track) }
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

      offset = @options[:offset]
      @offset =
        if offset
          offset = offset.to_i
          UI.term "Invalid offset value\nIt should be more or equal 0" if offset < 0
          offset
        else
          DEFAULT_OFFSET
        end
    end

    def add_track_to_queue(track)
      @queue << track
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
