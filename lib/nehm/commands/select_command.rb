require 'nehm/tracks_view'

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
      type = @options[:args].shift
      tracks_view = TracksView.new
      track_manager = TrackManager.new(@options)
      @limit = options[:limit] ? options[:limit].to_i : DEFAULT_LIMIT
      @offset = options[:offset] ? options[:offset].to_i : DEFAULT_OFFSET

      tracks_view.next_page_proc = self.method(:next_page)
      tracks_view.prev_page_proc = self.method(:prev_page)

      loop do
        tracks =
          case type
          when /l/
            track_manager.likes(@limit, @offset)
          when /p/
            track_manager.posts(@limit, @offset)
          when nil
            UI.term 'You must provide argument'
          else
            UI.term "Invalid argument/option '#{type}'"
          end

        tracks_view.view(tracks)

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

    def next_page
      @offset += @limit
    end

    def prev_page
      @offset -= @limit if @offset >= @limit
    end

  end
end
