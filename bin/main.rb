require 'telegram/bot' 

token = '1256706071:AAE_fzzEcpI0Y-GSDmAqO11mleVHxDOApuA'

Telegram::Bot::Client.run(token) do |bot|
  telegram_acc = ''
  pr_hash = {}
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Welcome, #{message.from.first_name}. Please authorize bot via OAuth, so I can help you.\n Type /auth and provide me your github account. #{telegram_acc}"
      )
    when '/stop'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Bye, #{message.from.first_name}"
      )
    when /\b(\w*github\w*)\b/
      telegram_acc = message.text
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "Thanks, your github account is #{telegram_acc}"
      )
    end
  end
end
