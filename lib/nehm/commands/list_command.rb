require 'nehm/tracks_view_command'

module Nehm

  ##
  # This command gets list of likes/posts from user's account,
  # Prints as menu, and downloads selected tracks

  class ListCommand < TracksViewCommand

    def initialize
      super

      add_option(:from, 'from PERMALINK',
                 'Get list of track(s) from user with PERMALINK')

      add_option(:to, 'to PATH',
                 'Download track(s) to PATH')

      add_option(:pl, 'pl PLAYLIST',
                 'Add track(s) to iTunes playlist with PLAYLIST name')

      add_option(:limit, 'limit NUMBER',
                 'Show NUMBER tracks on each page')

      add_option(:offset, 'offset NUMBER',
                 'Show from NUMBER+1 track')

      add_option(:dl, 'dl yes',
                 "Don't add tracks to iTunes. Just download and set tags")
    end

    def arguments
      { 'likes' => 'List of likes',
        'posts' => 'List of posts' }
    end

    def program_name
      'nehm list'
    end

    def execute
      @type = @options[:args].shift
      super
    end

    def summary
      'Get list of likes or posts from your account and download, set tags ' \
                                                  'and add to iTunes selected'
    end

    def usage
      "#{program_name} ARGUMENT [OPTIONS]"
    end

    protected

    def get_tracks
      case @type
      when /l/
        @track_manager.likes(@limit, @offset)
      when /p/
        @track_manager.posts(@limit, @offset)
      when nil
        UI.term 'You must provide an argument'
      else
        UI.term "Invalid argument/option '#{type}'"
      end
    end

  end
end
