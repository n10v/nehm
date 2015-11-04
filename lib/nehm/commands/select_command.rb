require 'nehm/tracks_view_command'

module Nehm

  ##
  # Write here description for command

  class SelectCommand < TracksViewCommand

    def initialize
      super

      add_option(:from, 'from PERMALINK',
                 'Select track(s) from user with PERMALINK')
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
