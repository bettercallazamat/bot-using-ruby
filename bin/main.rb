# coding: UTF-8
require "telegram/bot"

token = '1256706071:AAE_fzzEcpI0Y-GSDmAqO11mleVHxDOApuA'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Welcome, #{message.from.first_name}. Please authorize bot via OAuth, so I can help you.\n Type /auth and provide me your github account")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
      exit
    end
  end
end