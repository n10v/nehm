module Nehm
  class TracksView

    def view(tracks)
      # If tracks == nil, then there is a last page or there aren't tracks
      if tracks.nil?
        UI.error 'There are no more tracks'
        prev_page
        sleep(2)
        next
      end

      @queue = []

      UI.page_view do |page|
        page.header = 'Select track to add it to download queue'.green

        page.newline

        tracks.each do |track|
          page.choice(:inc, track.full_name) { add_track_to_queue(track) }
        end

        page.newline

        page.choice('d', 'Download tracks from queue'.green) { download_tracks_from_queue}
        page.choice('v', 'View added tracks'.green) { view_queue }
        page.choice('n', 'Next Page'.magenta) { @next_page_proc.call }
        page.choice('p', 'Prev Page'.magenta) { @prev_page_proc.call }
      end
    end

    def next_page_proc=(block)
      @next_page_proc = block
    end

    def prev_page_proc=(block)
      @prev_page_proc = block
    end

    module_function

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
