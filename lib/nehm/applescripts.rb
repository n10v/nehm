module AppleScripts
  def self.add_track_to_playlist(track_path, playlist_name)
    system("osascript #{File.join(applescripts_path, 'add_track_to_playlist.applescript')} #{track_path} #{playlist_name} > /dev/null")
  end

  def self.list_of_playlists
    output = `osascript #{File.join(applescripts_path, 'list_of_playlists.applescript')}`
    output.chomp.split(', ')
  end

  module_function

  def applescripts_path
    File.join(Gem::Specification.find_by_name('nehm').gem_dir, '/lib/nehm/applescripts/')
  end
end
