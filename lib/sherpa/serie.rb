module Sherpa
  class Serie
    attr_accessor :id,
                  :title,
                  :date,
                  :quality,
                  :season,
                  :episode,
                  :category,
                  :link,
                  :pub_date,
                  :content_length,
                  :hash,
                  :magnet_uri,
                  :seeds,
                  :peers,
                  :file_name,
                  :download_url,
                  :type,
                  :allocated_path,
                  :rss

    def initialize(opts = {})
      @id = opts[:id]
      @file_name = opts[:file_name]
      @rss = opts[:rss]
      @title   = opts[:title]
      @date    = opts[:date]
      @quality = opts[:quality]
      @season  = opts[:season]
      @episode = opts[:episode]
      @category = opts[:category]
      @link = opts[:link]
      @pub_date = opts[:pub_date]
      @content_length = opts[:content_length]
      @hash = opts[:hash]
      @magnet_uri = opts[:magnet_uri]
      @seeds = opts[:seeds]
      @peers = opts[:peers]
      @download_url = opts[:download_url]
      @type = opts[:type]
      @allocated_path = opts[:allocated_path]
    end

    def full_name
      @title.tr(' ', '.').downcase
    end

    def already_downloaded?
      params = if @date.nil?
                 { title: title,
                   season: season,
                   episode: episode }
               else
                 { title: title,
                   date: date }
               end
      @_persisted ||= Sherpa::Database.exist?(Sherpa::TV_TABLE_NAME, params)
    end

    def persist!
      # En la base de datos va en downcase y separada cada palabra por punto.
      params = {}
      attrs_persisted.each do |attr|
        params[attr] = send(attr)
      end
      Sherpa::Database.insert(Sherpa::TV_TABLE_NAME, params)
    end

    def attrs_persisted
      self.class.attrs_persisted
    end

    def self.attrs_persisted
      query = "Select * FROM #{Sherpa::TV_TABLE_NAME} LIMIT 0"
      attrs = Sherpa::Database.execute2(query).first.map(&:to_sym)
      attrs.delete(:id)
      attrs
    end

    def self.all
      query = Sherpa::Database.execute2("Select * FROM #{Sherpa::TV_TABLE_NAME}")
      keys = query.shift
      query.map do |sql|
        obj = {}
        sql.each_with_index do |value, index|
          obj[keys[index].to_sym] = value
        end
        Sherpa::Serie.new(obj)
      end
    end
  end
end
