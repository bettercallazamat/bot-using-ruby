# rubocop:disable Layout/LineLength
# rubocop:disable Metrics/BlockLength

require 'rubygems'
require 'telegram/bot'
require_relative '../lib/githubconnector.rb'
require_relative '../lib/user.rb'

token = '1256706071:AAE_fzzEcpI0Y-GSDmAqO11mleVHxDOApuA'

Telegram::Bot::Client.run(token) do |bot|
  pr_hash = {}
  github_acc = 'not defined'

  user_hash = {}

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
        github_repos = $github.repos(github_acc) unless github_acc == 'not defined'
        github_repos.each do |repo|
          pr_hash[repo] = 0
          pull_requests = $github.pull_requests(github_acc, repo)
          pull_requests.each do
            break if pull_requests.empty?

            i = 1
            loop do
              break unless $github.pr_exists?(github_acc, repo, i)

              pr_hash[repo] += $github.comments_num(github_acc, repo, i)
              i += 1
            end
          end
        end
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Updated #{pr_hash.select { |key, value| value > 0}}"
        )
      # when '/check'
      #   updated = []
      #   github_repos = []
      #   github_repos = $github.repos(github_acc) unless github_acc == 'not defined'
      #   if github_repos =
      #   github_repos.each do |repo|
      #     comments_number = 0
      #     pull_requests = $github.pull_requests(github_acc, repo)
      #     pull_requests.each do
      #       break if pull_requests.empty?

      #       i = 1
      #       loop do
      #         break unless $github.pr_exists?(github_acc, repo, i)

      #         comments_number += $github.comments_num(github_acc, repo, i)
      #         i += 1
      #       end
      #     end
      #     updated.push(repo) if comments_number > pr_hash[repo]
      #   end
      #   if updated.empty?
      #     bot.api.send_message(
      #       chat_id: message.chat.id,
      #       text: "No updates"
      #     )
      #   else
      #     bot.api.send_message(
      #       chat_id: message.chat.id,
      #       text: "There are updates in next repos #{updated}}"
      #     )
      #   end
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
