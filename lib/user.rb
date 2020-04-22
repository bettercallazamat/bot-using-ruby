class User
  attr_reader :github_acc, :telegram_id, :chat_id, :pull_requests
  attr_writer :pull_requests

  def initialize(github_acc, telegram_id, chat_id)
    @github_acc = github_acc
    @telegram_id = telegram_id
    @chat_id = chat_id
    @pull_requests = {}
  end
end
