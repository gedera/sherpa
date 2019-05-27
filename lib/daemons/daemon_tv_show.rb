class DaemonTvShow < ::DaemonTask
  def initialize(setting)
    super(setting)
  end

  def call
    @daemon_logger.debug("RUN DAEMON_TV_SHOW")

    unless File.exist?(SERIES_YAML_FILE)
      @daemon_logger.debug("file #{SERIES_YAML_FILE} not exist")
      return
    end

    settings = YAML::safe_load(File.open(SERIES_YAML_FILE).read)

    @daemon_logger.debug(settings)

    ::Rss::Ezrss.items.each do |serie|
      full_serie_name = serie['torrent:fileName']
      @daemon_logger.debug("RSS::EZRSS TvShow: #{full_serie_name}")
      match = TvShow.match_in_setting(full_serie_name, settings)

      next if match.blank?

      tv_show = TvShow.find_or_initialize_by(match)

      if tv_show.new_record?
        tv_show.file_name = full_serie_name
        tv_show.save
        tv_show.download_torrent
        @daemon_logger.info("Download #{tv_show.file_name} in #{tv_show.torrent_file}")
      else
        @daemon_logger.debug("Already Download: #{tv_show.file_name}")
      end
    end
  end
end
