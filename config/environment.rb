# Load the Rails application.
require_relative 'application'

DAEMON_NAME = 'sherpad'

SERIES_YAML_FILE = (Rails.root + 'data/series.yml').to_s
TORRENT_DIR = '/tmp/torrents/'
DOWNLOADS_DIR = '/tmp/downloads/'
TV_SHOW_DIR = '/tmp/tv_shows/'

dirs = [TORRENT_DIR, DOWNLOADS_DIR, TV_SHOW_DIR]

FileUtils.mkdir_p(dirs)
# Initialize the Rails application.
Rails.application.initialize!
