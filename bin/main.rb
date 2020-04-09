# coding: UTF-8
require "telegram/bot"

TOKEN = '1256706071:AAE_fzzEcpI0Y-GSDmAqO11mleVHxDOApuA'

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Welcome, #{message.from.first_name}.")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
      exit
    end
  end
end