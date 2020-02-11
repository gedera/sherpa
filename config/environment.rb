# Load the Rails application.
require_relative 'application'

DAEMON_NAME = 'sherpad'

TELEGRAM_USER_ID = ENV['TELEGRAM_GABIX_ID']

RTORRENT_TORRENT_DIR = ENV['RTORRENT_TORRENT_DIR']
RTORRENT_PORT = ENV['RTORRENT_PORT']
TELEGRAM_BOT_TOKEN = '961377040:AAEoYplyeZVhph56xXYsnrZFxIsVh_sAzh8'

CLOUD_NFS_DIR           = ENV['CLOUD_NFS_DIR']
CLOUD_NFS_TORRENTS_DIR  = [CLOUD_NFS_DIR, 'torrents'].join('/')
CLOUD_NFS_DOWNLOADS_DIR = [CLOUD_NFS_DIR, 'downloads'].join('/')
CLOUD_NFS_MOVIES_DIR    = [CLOUD_NFS_DIR, 'movies'].join('/')
CLOUD_NFS_SERIES_DIR    = [CLOUD_NFS_DIR, 'series'].join('/')

SETTINGS_DIR  = './data/settings/'
TORRENT_DIR   = CLOUD_NFS_TORRENTS_DIR # './data/torrents/'
DOWNLOADS_DIR = './data/downloads/'
TV_SHOW_DIR   = './data/tv_shows/'

SERIES_YAML_FILE = "#{SETTINGS_DIR}series.yml"

dirs = [SETTINGS_DIR, TORRENT_DIR, DOWNLOADS_DIR, TV_SHOW_DIR]

FileUtils.mkdir_p(dirs)
# Initialize the Rails application.
Rails.application.initialize!
