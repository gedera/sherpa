# Load the Rails application.
require_relative 'application'

DAEMON_NAME = 'sherpad'


SETTINGS_DIR = './data/settings/'
TORRENT_DIR = './data/torrents/'
DOWNLOADS_DIR = './data/downloads/'
TV_SHOW_DIR = './data/tv_shows/'

SERIES_YAML_FILE = "#{SETTINGS_DIR}series.yml"

dirs = [SETTINGS_DIR, TORRENT_DIR, DOWNLOADS_DIR, TV_SHOW_DIR]

FileUtils.mkdir_p(dirs)
# Initialize the Rails application.
Rails.application.initialize!
