module Downloader
  def self.get_http(name: file_name, rss: rss)
    uri = URI.parse("https://zoink.ch/torrent/")
    request = Net::HTTP::Get.new("https://zoink.ch/torrent/" + "#{name}.torrent")
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  end
end
