module Rss
  module Ezrss
    def self.xml
      @@xml ||= Nori.new.parse(%x"curl https://eztv.io/ezrss.xml")
    end

    def self.rss
      xml['rss']
    end

    def self.channel
      rss['channel']
    end

    def self.items
      channel['item']
    end

    def self.files_name
      items.map { |a| a['torrent:fileName'] }
    end

    def self.torrents
      @@torrents ||= items.map{ |item| Torrent.new(item) }
    end
  end
end
