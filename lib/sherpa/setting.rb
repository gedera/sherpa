module Sherpa
  class Setting

    SETTING_FILE_NAME = '/home/gabriel/.sherpa.yml'.freeze
    QUALITIES = ['720p', 'HDTV'].freeze

    attr_accessor :rss, :series, :quality

    def initialize(opts = {})
      @rss     = opts['rss']
      @series  = opts['series'].map { |serie| serie.tr(" ", ".").downcase }
      @quality = opts['quality']
    end

    def self.load
      @_settings ||= []
      return @_settings unless @_settings.empty?
      sherpa_setting = YAML::safe_load(File.open(Sherpa::Setting::SETTING_FILE_NAME).read)
      # Database.initialize(sherpa_setting['environment']['data_base_path'])

      sherpa_setting["rss"].each do |setting|
        puts "RSS #{setting['name']}"
        rss = Rss.build(setting['name'])
        QUALITIES.each do |quality|
          next if setting[quality].nil?
          setting[quality]['series']
          rss.series.each do |serie|
            puts "Source serie: #{serie.full_name}"
            if ((quality == serie.quality &&
                 setting[quality]['series'].include?(serie.title)) &&
                !serie.already_downloaded?)
              puts "DEscarga papa"
              # file_path = Sherpa::Downloader.download(rss.uri, serie.file_name)
              # unless file_path.nil?
              #   puts "Start to download: #{serie.name}"
              #   FileUtils.mv(file_path, TORRENT_DIR)
              #   serie.persist!
              # end
            end
          end
        end
      end
    rescue => e
      puts "Cant load file #{SETTING_FILE_NAME}: #{e}"
    end
  end
end
