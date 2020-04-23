# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/MethodLength
# rubocop:disable Layout/LineLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Style/ConditionalAssignment

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
    @users[telegram_id].pull_requests = {}
    github_repos = @github.repos(@users[telegram_id].github_acc)
    github_repos.each do |repo|
      pull_requests = @github.pull_requests(@users[telegram_id].github_acc, repo)
      pull_requests.each do |pr|
        @users[telegram_id].pull_requests[pr[2]] = @github.comments_num(@users[telegram_id].github_acc, repo, pr[1])
      end
    end
  end

  def check(telegram_id)
    updated = []
    github_repos = @github.repos(@users[telegram_id].github_acc)
    github_repos.each do |repo|
      pull_requests = @github.pull_requests(@users[telegram_id].github_acc, repo)
      pull_requests.each do |pr|
        comments_number = 0
        comments_number += @github.comments_num(@users[telegram_id].github_acc, repo, pr[1])
        updated.push(pr[2]) if comments_number > @users[telegram_id].pull_requests[pr[2]]
      end
    end
    updated
  end

  def looping_check(bot)
    loop do
      users_clone = @users.clone
      users_clone.each do |_key, value|
        updated = check(value.telegram_id) + check_pull_requests_diff(value.telegram_id)
        next if updated.empty?

        updated_string = ''
        updated.each { |repo| updated_string += repo + "\n" }
        content = "There are updates in next PR(s):\n#{updated_string}"
        text_reply(bot, value.chat_id, content)
        update(value.telegram_id)
      end
      sleep(600)
    end
  end

  def add_pull_requests_diff(telegram_id, input)
    input_arr = input.split('/')
    i = 1
    i = 3 if input_arr[0] == 'https:' || input_arr[0] == 'http:'
    username = input_arr[i]
    repo = input_arr[i + 1]
    number = input_arr[i + 3].to_i
    comments_number = @github.comments_num(username, repo, number)
    @users[telegram_id].pull_requests_diff[input] = [input, username, repo, number, comments_number]
  end

  def check_pull_requests_diff(telegram_id)
    updated = []
    @users[telegram_id].pull_requests_diff.each do |_key, value|
      comments_number = @github.comments_num(value[1], value[2], value[3])
      update = false
      update = true if comments_number > value[4]
      if update
        updated.push(value[0])
        value[4] = comments_number
      end
    end
    updated
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
      content = "/start - Starting a bot\n/stop - Stopping a bot\n/auth - Saves your GitHub username\n/username - Give you username that you have provided to bot\n/check - Checks if there are new feedbacks on your repos\n/add - to add PR from repository of your coding parter to track"
      text_reply(bot, message.chat.id, content)

    when '/auth'
      content = 'Please provide your username in github'
      text_reply(bot, message.chat.id, content)
      bot.listen do |username_input|
        @users[message.from.id] = User.new(username_input, message.from.id, message.chat.id)
        content = "Your GitHub acc is set to #{@users[message.from.id].github_acc} \n\nChecks will be done automatically every 10 minutes, but if you want to check for updates manually use /check command. \n\nIf you want to track pull request from repository of your coding parter use /add command and provide link to pull request."
        text_reply(bot, message.chat.id, content)
        break
      end
      update(message.from.id)

    when '/username'
      if @users[message.from.id].nil?
        content = "You haven't specified your github acc. Type /auth and provide me your github account."
      else
        content = "Your GitHub acc is set to #{@users[message.from.id].github_acc}"
      end
      text_reply(bot, message.chat.id, content)

    when '/check'
      if @users[message.from.id].nil?
        content = "You haven't specified your github acc. Type /auth and provide me your github account."
      else
        updated = check(message.from.id) + check_pull_requests_diff(message.from.id)
        if updated.empty?
          content = 'No updates'
        else
          updated_string = ''
          updated.each { |value| updated_string += value + "\n" }
          content = "There are updates in next PR(s):\n#{updated_string}"
          update(message.from.id)
        end
      end
      text_reply(bot, message.chat.id, content)

    when '/add'
      content = 'Please provide link to PR that you want to track'
      text_reply(bot, message.chat.id, content)
      bot.listen do |input|
        add_pull_requests_diff(message.from.id, input.text)
        content = 'PR is added to tracking list'
        text_reply(bot, message.chat.id, content)
        break
      end
    end
  end
end

# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/MethodLength
# rubocop:enable Layout/LineLength
# rubocop:enable Metrics/AbcSize
# rubocop:enable Style/ConditionalAssignment
