module SystemUtils
  # SystemUtils.download_file
  def self.download_file(url, file_name=nil)
    require 'open-uri'

    retries = 0

    file_name ||= CGI.unescape(url.split('/').last).underscore.tr(' ', '_')

    path = "#{TORRENT_DIR}#{file_name}"

    begin
      File.open(path, 'wb') do |file|
        file.write open(url).read
      end
    rescue Net::OpenTimeout, OpenURI::HTTPError, StandardError => e
      if retries < 3
        retries += 1
        retry
      end

      ::Rails.logger.error(e)
      nil
    end
  end

  # SystemUtils.scp_torrent
  def self.scp_torrent(file_name)
    file_path = "#{TORRENT_DIR}'#{file_name}'"
    command = Command.new("scp -P #{RTORRENT_PORT} #{file_path} #{RTORRENT_TORRENT_DIR}")
    command.exec
    if command.to_log[:status].zero?
      File.delete(file_path) if File.exist?(file_path)
      ::TelegramBot.send_message(TELEGRAM_USER_ID, "Moved to rtorrent")
    else
      ::TelegramBot.send_message(TELEGRAM_USER_ID, "#{command.to_log[:stderr]}")
    end
    command.to_log
  end

  # SystemUtils.move_torrents
  def self.move_torrents(file_name)
    file_path = "#{TORRENT_DIR}'#{file_name}'"
    command = Command.new("scp -P #{RTORRENT_PORT} #{file_path} #{RTORRENT_TORRENT_DIR}")
    command.exec
    if command.to_log[:status].zero?
      File.delete(file_path) if File.exist?(file_path)
      ::TelegramBot.send_message(TELEGRAM_USER_ID, "Moved to rtorrent")
    else
      ::TelegramBot.send_message(TELEGRAM_USER_ID, "#{command.to_log[:stderr]}")
    end
    command.to_log
  end
end
