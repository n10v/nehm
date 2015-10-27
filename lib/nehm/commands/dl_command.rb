module Nehm
  class DlCommand < Command

    def initialize
      super

      add_option(:from, 'from PERMALINK',
                 'Get track(s) from user with PERMALINK')

      add_option(:to, 'to PATH',
                 'Download track(s) to PATH')
    end

    def execute
      @options[:dl] = true

      get_cmd = CommandManager.command_instance('get')
      get_cmd.options = @options
      get_cmd.execute
    end

    def arguments
      { 'post'         => 'Download last post (track or repost) from your profile',
        'NUMBER posts' => 'Download last NUMBER posts from your profile',
        'like'         => 'Download your last like',
        'NUMBER likes' => 'Download your last NUMBER likes',
        'URL'          => 'Download track from entered URL' }
    end

    def program_name
      'nehm dl'
    end

    def summary
      'Download and set tags any track from SoundCloud'
    end

    def usage
      "#{program_name} ARGUMENT [OPTIONS]"
    end

  end
end
