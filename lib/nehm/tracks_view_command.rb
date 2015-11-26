module Nehm

  ##
  # TracksViewCommand is a super class for all commands, that show tracks
  # in list and let download selected tracks. When creating a new
  # TracksViewCommand, define #get_tracks (protected), #initialize, #arguments, #program_name,
  # #summary and #usage. You can also define #execute if you need, but
  # you must place also 'super' in this inherited method
  #
  # See 'list_command.rb' or 'search_command.rb' as example

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

    def get_tracks
      raise StandardError, "You must define 'get_tracks' method"
    end


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
      @limit = @options[:limit] ? @options[:limit].to_i : DEFAULT_LIMIT
      @offset = @options[:offset] ? @options[:offset].to_i : DEFAULT_OFFSET
    end

    def add_track_to_queue(track)
      @queue << track
    end

    def download_tracks_from_queue
      UI.newline
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
