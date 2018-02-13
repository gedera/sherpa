module Sherpa
  class Downloader

    def self.exec(settings = nil)
      settings.each do |setting|
        puts "RSS #{setting['name']}"
        rss = Rss.build(setting['name'])
        Sherpa::QUALITIES.each do |quality|
          next if setting[quality].nil?
          setting[quality]['series']
          rss.series.each do |serie|
            puts "Source serie: #{serie.full_name}"
            next unless quality == serie.quality &&
                        setting[quality]['series'].include?(serie.title) &&
                        !serie.already_downloaded?
            file_path = download(rss.uri, serie.file_name)
            unless file_path.nil?
              puts "Start to download: #{serie.name}"
              FileUtils.mv(file_path, Sherpa::TORRENT_DIR)
              #serie.persist!
            end
          end
        end
      end
    end

    def self.get_http(uri, file_name)
      uri = URI.parse(uri)
      request = Net::HTTP::Get.new(uri + "#{file_name}.torrent")
      Net::HTTP.start(uri.host,
                      uri.port,
                      use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
    rescue => e
      puts "cant get_http for #{file_name}: #{e.message}"
      nil
    end

    def self.download(uri, file_name)
      response = get_http(uri, file_name)
      return response if response.nil?
      if response.code == "200"
        file = TempFile.open("#{file_name}.torrent", "wb")
        file.write(response.body)
        file.path
      end
    rescue => e
      puts "cant download #{file_name}: #{e.message}"
      nil
    end
  end
end
