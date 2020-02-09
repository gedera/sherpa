class Movie < ApplicationRecord

  enum state: %i[downloading moved]

  def self.parse(file_name)
    result = /(.+)[.|\s](\d{4,})[.|\s](\d+p)/.match(file_name)
    resp = if result.blank?
             ::TelegramBot.send_message(TELEGRAM_USER_ID, "Cant parse #{file_name}")
             { status: false }
           else
             { title: result[1].underscore.tr(' ', '.'),
               year: result[2].to_i,
               quality: result[3],
               file_name: file_name }
           end
    { status: true, response: resp }
  rescue => e
    Rails.logger.error(e)
    { status: false }
  end
end
