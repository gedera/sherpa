module Sherpa
  class Database

    def self.initialize!
      $sqlite_connection = SQLite3::Database.new(Sherpa::DATABASE_FILE)
      execute "CREATE TABLE IF NOT EXISTS #{Sherpa::TV_TABLE_NAME}" \
              '(id INTEGER PRIMARY KEY, ' \
              'title TEXT, ' \
              'season TEXT, ' \
              'episode TEXT, ' \
              'rss TEXT, ' \
              'sub_en INTEGER default 0, ' \
              'sub_es INTEGER default 0, ' \
              'date TEXT, ' \
              'file_name TEXT, ' \
              'created_at DATETIME DEFAULT CURRENT_TIMESTAMP)'
      puts "Sqlite version:" + $sqlite_connection.get_first_value('SELECT SQLITE_VERSION()')
    rescue SQLite3::Exception => e
      puts "Exception occurred"
      puts e
    end

    def self.execute(query)
      $sqlite_connection.execute(query)
    end

    def self.execute2(query)
      $sqlite_connection.execute2(query)
    end

    def self.prepare(query)
      $sqlite_connection.prepare(query)
    end

    def self.exist?(table, arguments)
      where = arguments.map { |k, v| "#{k} = '#{v}'" }.join(" AND ")
      !execute("SELECT * FROM #{table} WHERE #{where}").empty?
    end

    def self.insert(table, arguments)
      keys = arguments.keys.join(', ')
      values = arguments.values.map { |v| "'#{v}'" }.join(', ')
      execute("INSERT INTO #{table}(#{keys}) VALUES(#{values})")
    end

    def self.populate
      digging(Sherpa::MEDIA_TV_FILES_DIR).each do |serie|
        serie.persist! unless serie.already_downloaded?
      end
    end

    def self.insert_column(name, type, default = nil)
      column = [name, type]
      column += ['default', default] unless default.nil?
      puts "ALTER TABLE #{Sherpa::TV_TABLE_NAME} ADD COLUMN #{column.join(' ')}"
      execute "ALTER TABLE #{Sherpa::TV_TABLE_NAME} ADD COLUMN #{column.join(' ')}"
    end
  end
end
