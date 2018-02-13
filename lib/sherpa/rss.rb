module Sherpa
  class Rss
      attr_accessor :name, :uri, :xml_response, :version, :xmlns_torrent, :title, :link, :description, :xmlns_torrent, :series

      EZTV_SOURCE = 'https://eztv.ag/ezrss.xml'

      def initialize(attrs = {})
        @name = attrs[:name]
        @xml_response = attrs[:xml_response]
        @uri = attrs[:uri]
        @title = attrs[:title]
        @link = attrs[:link]
        @description = attrs[:description]
        @xmlns_torrent = attrs[:xmlns_torrent]
        @version = attrs[:version]
        @series = attrs[:series]
      rescue => e
        puts "Cant create Rss model: #{e.message}"
        raise e.message
      end

      def self.build(rss)
        send(rss)
      end

      def self.parse_file_name(file_name)
        # result[0] # same as full_serie_name
        # result[1] # serie name
        # result[2] # season
        # result[3] # episode
        result = {}
        result[:quality] = 'HDTV'  if file_name.include?('HDTV')
        result[:quality] = '720p'  if file_name.include?('720p')
        result[:quality] = '1080p' if file_name.include?('1080p')

        episode_and_season = /(\S*).S(\d{2,3})E(\d{2,3}).*/.match(file_name) # match with name.SXXEXX
        name_with_date = /(\S*).(\d{4}.\d{2}.\d{2}).*/.match(file_name)
        only_name = /(\S*).(HDTV|720p|1080p).HDTV*/.match(file_name)

        if episode_and_season
          result[:title] = episode_and_season[1].downcase
          result[:season] = episode_and_season[2]
          result[:episode] = episode_and_season[3]
        elsif name_with_date
          result[:title] = name_with_date[1].downcase
          result[:date] = name_with_date[2]
        elsif only_name
          resut[:title] = only_name[1].downcase
        else
          { title: nil,
            quality: nil,
            season: nil,
            episode: nil,
            date: nil }
        end
        result
      rescue => e
        puts "Cant parse #{@file_name}"
        { title: nil,
          quality: nil,
          season: nil,
          episode: nil,
          date: nil }
      end

      def self.eztv
        attrs = { xml_response: Nori.new.parse(`curl #{EZTV_SOURCE}`),
                  name: 'eztv',
                  uri: 'https://zoink.ch/torrent/' }
        attrs[:title] = attrs[:xml_response]['rss']['channel']['title']
        attrs[:link] = attrs[:xml_response]['rss']['channel']['link']
        attrs[:description] = attrs[:xml_response]['rss']['channel']['description']
        attrs[:xmlns_torrent] = attrs[:xml_response]['rss']['@xmlns:torrent']
        attrs[:version] = attrs[:xml_response]['rss']['@version']
        attrs[:series] = []
        attrs[:xml_response]['rss']['channel']['item'].each do |serie|
          attrs_serie = {
            rss: 'eztv',
            file_name: serie['torrent:fileName'],
            seeds: serie['torrent:seeds'],
            peers: serie['torrent:peers'],
            category: serie['category'],
            link: serie['link'],
            pub_date: serie['pubDate'],
            content_length: serie['torrent:contentLength'],
            hash: serie['torrent:infoHash'],
            magnet_uri: serie['torrent:magnetURI'],
            download_url: (serie['enclosure']['@url'] rescue nil),
            type: (serie['enclosure']['@type'] rescue nil),
            allocated_path: 'eztv_soruce'
          }
          file_name_parsed = parse_file_name(attrs_serie[:file_name])
          if file_name_parsed[:title].nil?
            puts "Can't parse #{attrs_serie[:file_name]}"
          else
            attrs_serie.merge!(file_name_parsed)
            attrs[:series] << Sherpa::Serie.new(attrs_serie)
          end
        end
        new(attrs)
      end
  end
end
