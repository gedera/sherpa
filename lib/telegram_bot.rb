# coding: utf-8
module TelegramBot

  # TelegramBot.download_document
  def self.download_document(id, file_name, file_id)
    uri = URI.parse("https://api.telegram.org/")
    request = Net::HTTP::Get.new("https://api.telegram.org/bot#{id}/getFile?file_id=#{file_id}")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
    body = JSON.parse(response.body)
    file_path = body["result"]["file_path"]
    SystemUtils.download_file("https://api.telegram.org/file/bot#{id}/#{file_path}", file_name)
    ::TelegramBot.send_message(TELEGRAM_USER_ID, "Download #{file_name}")
  end

  def self.send_message(id, message)
    client = Telegram::Bot::Client.new(TELEGRAM_BOT_TOKEN)
    client.api.send_message(chat_id: id, text: message)
  end

  # TelegramBot,run!
  def self.run!
    Telegram::Bot::Client.run(TELEGRAM_BOT_TOKEN) do |bot|
      bot.listen do |message|
        case message.text
        when '/start'
          bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
        when '/stop'
          bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
        when /^\/download\s(.*)/
          bot.api.send_message(chat_id: message.chat.id, text: "Algun dia estará implementado")
        else
          if message.document.present? && message.caption == 'torrent'
            TelegramBot.download_document(TELEGRAM_BOT_TOKEN, message.document.file_name, message.document.file_id)
            SystemUtils.move_torrents(message.document.file_name)
          else
            bot.api.send_message(chat_id: message.chat.id, text: "Chupala no se que queres que haga")
          end
        end
      end
    end
  end
end
