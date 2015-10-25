module Nehm
  class TracksView

    attr_writer :next_page_proc, :prev_page_proc

    def view(tracks)
      @queue = []

      UI.menu do |menu|
        menu.header = 'Select track to add it to download queue'.green

        menu.newline

        tracks.each do |track|
          menu.choice(:inc, track.full_name) { add_track_to_queue(track) }
        end

        menu.newline

        menu.choice('d', 'Download tracks from queue'.green.freeze) { download_tracks_from_queue }
        menu.choice('v', 'View added tracks'.green.freeze) { view_queue }
        menu.choice('n', 'Next page'.magenta.freeze) { @next_page_proc.call }
        menu.choice('p', 'Prev page'.magenta.freeze) { @prev_page_proc.call }
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
