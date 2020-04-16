require 'rubygems'
require 'telegram/bot'
require_relative './githubconnector.rb'
require_relative './user.rb'

class Bot
  def initialize
    @users = {}
    @github = GitHubConnector.new
    token = ENV['TELEGRAM_BOT_TOKEN']
    begin
      Telegram::Bot::Client.run(token) do |bot|
        bot.listen { |message| command(bot, message) }
      end
    rescue Telegram::Bot::Exceptions::ResponseError => e
      puts 'Telegram Bot API issue' if e.error_code.to_s == '502'
    end
  end

  private

  def text_reply(bot, message, content)
    bot.api.send_message(chat_id: message.chat.id, text: content)
  end

  def update(message)
    github_repos = @github.repos(@users[message.from.id].github_acc)
    github_repos.each do |repo|
      @users[message.from.id].repos[repo] = 0
      i = 1
      loop do
        break unless @github.pr_exists?(@users[message.from.id].github_acc, repo, i)

        @users[message.from.id].repos[repo] += @github.comments_num(@users[message.from.id].github_acc, repo, i)
        i += 1
      end
    end
  end

  def check(message)
    updated = []
    github_repos = @github.repos(@users[message.from.id].github_acc)
    github_repos.each do |repo|
      comments_number = 0
      i = 1
      loop do
        break unless @github.pr_exists?(@users[message.from.id].github_acc, repo, i)

        comments_number += @github.comments_num(@users[message.from.id].github_acc, repo, i)
        i += 1
      end
      updated.push(repo) if comments_number > @users[message.from.id].repos[repo]
    end
    updated
  end

  def command(bot, message)
    case message.text
    when '/start'
      name = message.from.first_name
      content = "Welcome, #{name}. Type /auth and provide me your github account."
      text_reply(bot, message, content)
    when '/stop'
      content = "Bye, bye"
      text_reply(bot, message, content)
    when '/help'
      content = "/start - Starting a bot\n/stop - Stopping a bot\n/auth - Saves your GitHub username\n/username - Give you username that you have provided to bot\n/update - Saves your current state of your repos\n/check - Checks if there are new feedbacks on your repos"
      text_reply(bot, message, content)
    when '/auth'
      content = 'Please provide your username in github'
      text_reply(bot, message, content)
      bot.listen do |username_input|
        @users[message.from.id] = User.new(username_input)
        content = "Your GitHub acc is set to #{@users[message.from.id].github_acc}"
        text_reply(bot, message, content)
        break
      end
    when '/username'
      if @users[message.from.id].nil?
        content = "You haven't specified your github acc. Type /auth and provide me your github account."
      else
        content = "Your GitHub acc is set to #{@users[message.from.id].github_acc}"
      end
      text_reply(bot, message, content)
    when '/update'
      if @users[message.from.id].nil?
        content = "You haven't specified your github acc. Type /auth and provide me your github account."
      else
        update(message)
        content = "Updated.#{@users[message.from.id].repos.select { |_key, value| value > 0 }}"
      end
      text_reply(bot, message, content)
    when '/check'
      if @users[message.from.id].nil?
        content = "You haven't specified your github acc. Type /auth and provide me your github account."
      else
        updated = check(message)
        if updated.empty?
          content = 'No updates'
        else
          updated_string = ''
          updated.each { |value| updated_string += value + ' ' }
          content = "There are updates in next repos: #{updated_string}"
          update(message)
        end
      end
      text_reply(bot, message, content)
    end
  end
end
