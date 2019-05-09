class DaemonTvShow < ::Sherpa::DaemonTask
  def initialize(setting)
    super(setting)
  end

  def call
    return unless File.exist?(SERIES_YAML_FILE)

    settings = YAML::safe_load(File.open(SERIES_YAML_FILE).read)

    Rss::Ezrss.items.each do |serie|
      full_serie_name = serie['torrent:fileName']
      match = TvShow.match_in_setting(full_serie_name, settings)

      next unless match.present?
      tv_show = TvShow.find_or_initialize_by(match)

      if tv_show.new_record?
        tv_show.file_name = full_serie_name
        tv_show.save
        Rails.logger.info("Download #{tv_show.file_name}")
        tv_show.download_torrent
      end
    end
  end
end
