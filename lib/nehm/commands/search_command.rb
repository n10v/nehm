require 'nehm/tracks_view_command'

module Nehm

  class SearchCommand < TracksViewCommand

    def initialize
      super

      add_option(:"-t", '-t PATH',
                 'Download track(s) to PATH')

      add_option(:"-pl", '-pl PLAYLIST',
                 'Add track(s) to iTunes playlist with PLAYLIST name')

      add_option(:"-lim", '-lim NUMBER',
                 'Show NUMBER tracks on each page')

    end

    def execute
      # Convert dash-options to normal options
      options_to_convert = { :"-t"   => :to,
                            :"-pl"  => :pl,
                            :"-lim" => :limit }

      options_to_convert.each do |k,v|
        value = @options[k]
        @options.delete(k)
        @options[v] = value unless value.nil?
      end

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

      @track_manager.search(@query, @limit)
    end

  end
end
