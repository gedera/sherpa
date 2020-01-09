# Load the Rails application.
require_relative 'application'

DAEMON_NAME = 'sherpad'

TELEGRAM_USER_ID = ENV['TELEGRAM_GABIX_ID']

RTORRENT_TORRENT_DIR = ENV['RTORRENT_TORRENT_DIR']
RTORRENT_PORT = ENV['RTORRENT_PORT']

SETTINGS_DIR = './data/settings/'
TORRENT_DIR = './data/torrents/'
DOWNLOADS_DIR = './data/downloads/'
TV_SHOW_DIR = './data/tv_shows/'

SERIES_YAML_FILE = "#{SETTINGS_DIR}series.yml"

TELEGRAM_BOT_TOKEN = '961377040:AAEoYplyeZVhph56xXYsnrZFxIsVh_sAzh8'

dirs = [SETTINGS_DIR, TORRENT_DIR, DOWNLOADS_DIR, TV_SHOW_DIR]

FileUtils.mkdir_p(dirs)
# Initialize the Rails application.
Rails.application.initialize!
