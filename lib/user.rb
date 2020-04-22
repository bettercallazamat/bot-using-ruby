class User
  attr_reader :github_acc, :telegram_id, :chat_id, :pull_requests, :pull_requests_diff
  attr_writer :pull_requests, :pull_requests_diff

  def initialize(github_acc, telegram_id, chat_id)
    @github_acc = github_acc
    @telegram_id = telegram_id
    @chat_id = chat_id
    @pull_requests = {}
    @pull_requests_diff = {}
  end
end
