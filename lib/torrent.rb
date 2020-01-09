class Torrent
  attr_accessor :title,
                :category,
                :link,
                :guid,
                :pubDate,
                :torrent_content_length,
                :torrent_info_hash,
                :torrent_magnet_uri,
                :torrent_seeds,
                :torrent_peers,
                :torrent_verified,
                :torrent_file_name,
                :enclosure

  def new(attrs)
    @title = attrs['title']
    @category = attrs['category']
    @link = attrs['link']
    @guid = attrs['guid']
    @pubDate = attrs['pubDate']
    @torrent_content_length = attrs['torrent:contentLength']
    @torrent_info_hash = attrs['torrent:infoHash']
    @torrent_magnet_uri = attrs['torrent:magnetURI']
    @torrent_seeds = attrs['torrent:seeds']
    @torrent_peers = attrs['torrent:peers']
    @torrent_verified = attrs['torrent:verified']
    @torrent_file_name = attrs['torrent:fileName']
    @enclosure = attrs['enclosure']
  end
end
