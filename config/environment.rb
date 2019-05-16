# Load the Rails application.
require_relative 'application'

DAEMON_NAME = 'sherpad'

SERIES_YAML_FILE = ENV['SERIES_YAML_FILE']
TORRENT_DIR = ENV['TORRENT_DIR']
DOWNLOADS_DIR = ENV['DOWNLOADS_DIR']
TV_SHOW_DIR = ENV['TV_SHOW_DIR']

dirs = [TORRENT_DIR, DOWNLOADS_DIR, TV_SHOW_DIR]

FileUtils.mkdir_p(dirs)
# Initialize the Rails application.
Rails.application.initialize!
