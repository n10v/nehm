require 'nehm/tracks_view_command'

module Nehm

  class SearchCommand < TracksViewCommand

    def initialize
      super
    end

    def execute
      @query = @options[:args].join(' ')
      super
    end

    def arguments
      { 'QUERY' => 'Search query' }
    end

    def program_name
      'nehm search'
    end

    def summary
      'Search tracks, print them nicely and download selected tracks'
    end

    def usage
      "#{program_name} QUERY [OPTIONS]"
    end

    protected

    def get_tracks
      UI.term 'You must provide an argument' if @query.empty?

      @track_manager.search(@query, @limit, @offset)
    end

  end
end
