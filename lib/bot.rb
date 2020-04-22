# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/MethodLength
# rubocop:disable Layout/LineLength
# rubocop:disable Style/ConditionalAssignment
# rubocop:disable Metrics/AbcSize

require 'rubygems'
require 'telegram/bot'
require_relative 'githubconnector.rb'
require_relative 'user.rb'

class Bot
  attr_reader :users
  def initialize
    @users = {}
    @github = GitHubConnector.new
    token = ENV['TELEGRAM_BOT_TOKEN']
    begin
      Telegram::Bot::Client.run(token) do |bot|
        bot.listen do |message|
          command(bot, message)
          Thread.new { looping_check(bot) }
        end
      end
    rescue Telegram::Bot::Exceptions::ResponseError => e
      puts 'Telegram Bot API issue' if e.error_code.to_s == '502'
    end
  end

  private

  def text_reply(bot, chat_id, content)
    bot.api.send_message(chat_id: chat_id, text: content)
  end

  def update(telegram_id)
    github_repos = @github.repos(@users[telegram_id].github_acc)
    github_repos.each do |repo|
      @users[telegram_id].repos[repo] = 0
      pull_requests = @github.pull_requests(@users[telegram_id].github_acc, repo)
      i = 0
      while i < pull_requests.length
        @users[telegram_id].repos[repo] += @github.comments_num(@users[telegram_id].github_acc, repo, pull_requests[i][1])
        i += 1
      end
    end
  end

  def check(telegram_id)
    updated = []
    github_repos = @github.repos(@users[telegram_id].github_acc)
    github_repos.each do |repo|
      comments_number = 0
      pull_requests = @github.pull_requests(@users[telegram_id].github_acc, repo)
      i = 0
      while i < pull_requests.length
        comments_number += @github.comments_num(@users[telegram_id].github_acc, repo, pull_requests[i][1])
        i += 1
      end
      updated.push(repo) if comments_number > @users[telegram_id].repos[repo]
    end
    updated
  end

  def looping_check(bot)
    loop do
      users_clone = @users.clone
      users_clone.each do |_key, value|
        updated = check(value.telegram_id)
        next if updated.empty?

        updated_string = ''
        updated.each { |repo| updated_string += repo + ' ' }
        content = "There are updates in next repos: #{updated_string}"
        text_reply(bot, value.chat_id, content)
        update(value.telegram_id)
      end
      sleep(600)
    end
  end

  def command(bot, message)
    case message.text
    when '/start'
      name = message.from.first_name
      content = "Welcome, #{name}. Type /auth and provide me your github account."
      text_reply(bot, message.chat.id, content)
    when '/stop'
      content = 'Bye, bye'
      text_reply(bot, message.chat.id, content)
    when '/help'
      content = "/start - Starting a bot\n/stop - Stopping a bot\n/auth - Saves your GitHub username\n/username - Give you username that you have provided to bot\n/check - Checks if there are new feedbacks on your repos"
      text_reply(bot, message.chat.id, content)
    when '/auth'
      content = 'Please provide your username in github'
      text_reply(bot, message.chat.id, content)
      bot.listen do |username_input|
        @users[message.from.id] = User.new(username_input, message.from.id, message.chat.id)
        content = "Your GitHub acc is set to #{@users[message.from.id].github_acc}"
        text_reply(bot, message.chat.id, content)
        break
      end
      update(message.from.id)
    when '/username'
      if @users[message.from.id].nil?
        content = "You haven't specified your github acc. Type /auth and provide me your github account."
      else
        content = "Your GitHub acc is set to #{@users[message.from.id].github_acc} #{@users[message.from.id].repos}"
      end
      text_reply(bot, message.chat.id, content)
    when '/check'
      if @users[message.from.id].nil?
        content = "You haven't specified your github acc. Type /auth and provide me your github account."
      else
        updated = check(message.from.id)
        if updated.empty?
          content = 'No updates'
        else
          updated_string = ''
          updated.each { |value| updated_string += value + ' ' }
          content = "There are updates in next repos: #{updated_string}"
          update(message.from.id)
        end
      end
      text_reply(bot, message.chat.id, content)
    end
  end
end

# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/MethodLength
# rubocop:enable Layout/LineLength
# rubocop:enable Style/ConditionalAssignment
# rubocop:enable Metrics/AbcSize
