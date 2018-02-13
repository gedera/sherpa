require "sherpa/version"
require 'fileutils'
require 'net/http'
require 'yaml'
require 'erb'
require 'nori'
require 'sqlite3'

#require 'binding_of_caller'
require 'pry'

module Sherpa
  %w(
    setting
    rss
    serie
    downloader
    database
  ).each do |file|
    require "sherpa/#{file}"
  end
  # Your code goes here...

  SETTING_FILE_NAME = '/home/gabriel/.sherpa.yml'.freeze
  QUALITIES = %w[720p 1080p HDTV].freeze
  TV_TABLE_NAME = 'series'.freeze

  sherpa_setting = YAML::safe_load(File.open(Sherpa::SETTING_FILE_NAME).read)

  DATABASE_FILE = sherpa_setting['environment']['data_base_file']
  puts "DATABASE_FILE #{DATABASE_FILE}"
  TORRENT_DIR = sherpa_setting['environment']['torrent_dir']
  puts "TORRENT_DIR #{TORRENT_DIR}"
  DOWNLOADED_TORRENT_DIR = sherpa_setting['environment']['downloaded_torrent_dir']
  puts "DOWNLOADED_TORRENT_DIR #{DOWNLOADED_TORRENT_DIR}"
  MEDIA_TV_FILES_DIR = sherpa_setting['environment']['media_tv_files_dir']
  puts "MEDIA_TV_FILES_DIR #{MEDIA_TV_FILES_DIR}"
  Database.initialize!
  #Sherpa::Downloader.exec(sherpa_setting['rss'])
end
