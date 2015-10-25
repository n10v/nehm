module Nehm
  class TracksView

    attr_writer :next_page_proc, :prev_page_proc

    def view(tracks)
      @queue = []

      UI.page_view do |page|
        page.header = 'Select track to add it to download queue'.green

        page.newline

        tracks.each do |track|
          page.choice(:inc, track.full_name) { add_track_to_queue(track) }
        end

        page.newline

        page.choice('d', 'Download tracks from queue'.green) { download_tracks_from_queue }
        page.choice('v', 'View added tracks'.green) { view_queue }
        page.choice('n', 'Next Page'.magenta) { @next_page_proc.call }
        page.choice('p', 'Prev Page'.magenta) { @prev_page_proc.call }
      end
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
