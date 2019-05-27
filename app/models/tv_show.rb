class TvShow < ApplicationRecord

  scope :not_moved, -> { where(moved_to_media: false) }

  def download_torrent
    response = Downloader.get_http(name: file_name, rss: rss)
    if response.code == "200"
      # file = Tempfile.new("#{file_name}.torrent")
      file = File.open(torrent_file, "wb")
      file.write(response.body)
      file.path
    end
  end

  def torrent_file
    "#{TORRENT_DIR}#{file_name}.torrent"
  end

  def download_file
    "#{DOWNLOADS_DIR}#{file_name}"
  end

  def media_center_file
    return if season.blank?

    "#{media_center_dir}#{file_name}"
  end

  def media_center_dir
    return if season.blank?

    "#{TV_SHOW_DIR}#{title}/#{season_dir}"
  end

  def season_dir
    "season_#{season}/"
  end

  def self.move_to_tv_show_dir
    require 'fileutils'

    TvShow.not_moved.each do |tv_show|
      next unless File.exist?(tv_show.download_file)

      if tv_show.season.present?
        FileUtils.mkdir_p(tv.media_center_dir)
        FileUtils.mv(tv_show.download_file, media_center_file)
        tv_show.update_columns(moved_to_media: true)
      end
    end
  end

  def self.parse(name)
    # result[0] # same as full_serie_name
    # result[1] # serie name
    # result[2] # season
    # result[3] # episode
    result = /(\S*).[s|S](\d{2,3})[e|E](\d{2,3}).*/.match(name) # match with name.SXXEXX
    resp = if result.nil? # match with name.date
             result = /(\S*).(\d{4}.\d{2}.\d{2}).*/.match(name)
             { title: result[1], date: result[2] }
           else
             { title: result[1], season: result[2], episode: result[3] }
           end
    { status: true, response: resp }
  rescue => e
    puts "Cant parse #{name}"
    { status: false }
  end


  def self.match_in_setting(name, series_setting)
    result = nil
    tv_show_parsed = TvShow.parse(name)

    return unless tv_show_parsed[:status]

    series_setting.values.each do |setting|
      setting['series'].each do |title|
        title_with_dot = title.tr(' ', '.')
        if title_with_dot.casecmp(tv_show_parsed[:response][:title]).zero? && TvShow.check_quality?(name, setting['quality'])
          return {
            title: title_with_dot,
            quality: setting['quality'],
            rss: setting['rss'],
            season: tv_show_parsed[:response][:season],
            episode: tv_show_parsed[:response][:episode],
            date: tv_show_parsed[:response][:date]
          }
        end
      end
    end
    result
  end

  def self.check_quality?(name, quality)
    result = false
    result = name.include?(quality)
    result = !(name.include?('720p') || name.include?('1080p')) if (result && quality == 'HDTV')
    result
  rescue
    Rails.logger.error "Cant check quality #{name} - #{quality}"
    false
  end
end
