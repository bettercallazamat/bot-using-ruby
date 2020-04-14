# frozen_string_literal: true

# rubocop:disable Layout/LineLength
# rubocop:disable Metrics/BlockLength
# rubocop:disable Style/GlobalVars

require 'rubygems'
require 'telegram/bot'
require_relative '../lib/githubconnector.rb'

Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
  users_hash = {}

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
          users_hash[message.from.id] = [username_input, _repo_hash = {}]
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "Your GitHub acc is set to #{users_hash[message.from.id][0]}"
          )
          break
        end
      when '/username'
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "Your GitHub acc is set to @#{users_hash[message.from.id][0]}"
        )
      when '/update'
        if users_hash[message.from.id].nil?
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "You haven't specified your github acc. Type /auth and provide me your github account."
          )
        else
          github_repos = $github.repos(users_hash[message.from.id][0])
          github_repos.each do |repo|
            users_hash[message.from.id][1][repo] = 0
            pull_requests = $github.pull_requests(users_hash[message.from.id][0], repo)
            pull_requests.each do
              break if pull_requests.empty?

              i = 1
              loop do
                break unless $github.pr_exists?(users_hash[message.from.id][0], repo, i)

                users_hash[message.from.id][1][repo] += $github.comments_num(users_hash[message.from.id][0], repo, i)
                i += 1
              end
            end
          end
          bot.api.send_message(
            chat_id: message.chat.id,
            text: 'Updated.'
          )
        end
      when '/check'
        if users_hash[message.from.id].nil?
          bot.api.send_message(
            chat_id: message.chat.id,
            text: "You haven't specified your github acc. Type /auth and provide me your github account."
          )
        else
          updated = []
          github_repos = $github.repos(users_hash[message.from.id][0])
          github_repos.each do |repo|
            comments_number = 0
            pull_requests = $github.pull_requests(users_hash[message.from.id][0], repo)
            pull_requests.each do
              break if pull_requests.empty?

              i = 1
              loop do
                break unless $github.pr_exists?(users_hash[message.from.id][0], repo, i)

                comments_number += $github.comments_num(users_hash[message.from.id][0], repo, i)
                i += 1
              end
            end
            updated.push(repo) if comments_number > users_hash[message.from.id][1][repo]
          end
          if updated.empty?
            bot.api.send_message(
              chat_id: message.chat.id,
              text: 'No updates'
            )
          else
            updated_string = ''
            updated.each { |value| updated_string += value + ' ' }
            bot.api.send_message(
              chat_id: message.chat.id,
              text: "There are updates in next repos: #{updated_string}"
            )
          end
        end
      end
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    puts 'Telegram Bot API issue' if e.error_code.to_s == '502'
  end
end

# rubocop:enable Layout/LineLength
# rubocop:enable Metrics/BlockLength
# rubocop:enable Style/GlobalVars
