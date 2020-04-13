# rubocop:disable Layout/LineLength
# rubocop:disable Metrics/BlockLength

require 'rubygems'
require 'telegram/bot'
require './lib/githubconnector.rb'
require './lib/user.rb'

token = '1256706071:AAE_fzzEcpI0Y-GSDmAqO11mleVHxDOApuA'

Telegram::Bot::Client.run(token) do |bot|
  pr_hash = {}
  github_acc = ''
  begin
    bot.listen do |message|
      case message.text
      when '/start'
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Welcome, #{message.from.first_name}. Type /auth and provide me your github account."
        )
      when '/stop'
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Bye, #{message.from.first_name}"
        )
      when '/auth'
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "#{message.from.first_name} please provide your username in github"
        )
        bot.listen do |username_input|
          github_acc = username_input
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Your GitHub acc is set to #{github_acc}"
          )
          break
        end
      when '/username'
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Your GitHub acc is set to @#{github_acc}"
        )
      when '/update'
        github = GitHubConnector.new
        github_repos = github.repos(github_acc)
        puts github_repos
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Updated'
        )
      end
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    if e.error_code.to_s == '502'
      puts 'telegram stuff, nothing to worry!'
    end
  end
end

# rubocop:enable Layout/LineLength
# rubocop:enable Metrics/BlockLength
