module Nehm
  class TracksViewCommand < Command

    DEFAULT_LIMIT = 10

    DEFAULT_OFFSET = 0

    def initialize
      super

      add_option(:to, 'to PATH',
                 'Download track(s) to PATH')

      add_option(:pl, 'pl PLAYLIST',
                 'Add track(s) to iTunes playlist with PLAYLIST name')

      add_option(:limit, 'limit NUMBER',
                 'Show NUMBER tracks on each page')

      add_option(:offset, 'offset NUMBER',
                 'Show from NUMBER track')

    end

    def execute
      tracks = []
      old_offset = -1

      @queue = []
      @type = @options[:args].shift
      @track_manager = TrackManager.new(@options)

      setup_environment

      loop do
        # If offset changed
        unless old_offset == @offset
          tracks = get_tracks
          old_offset = @offset
        end

        # If tracks == nil, then there is a last page or there aren't tracks
        if tracks.nil?
          UI.error 'There are no more tracks'
          prev_page
          sleep(1)
          next
        end

        show_menu(tracks)
      end
    end

    protected

    def get_tracks; end

    def show_menu(tracks)
      UI.menu do |menu|
        menu.header = 'Select track to add it to download queue'.green

        menu.newline

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
      UI.success "'#{track.full_name}' added"
      sleep(1)
    end

    def already_added(track)
      UI.warning "'#{track.full_name}' was already added"
      sleep(1)
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
