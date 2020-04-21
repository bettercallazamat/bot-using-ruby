class User
  attr_reader :github_acc, :telegram_id, :chat_id, :repos
  attr_writer :repos

  def initialize(github_acc, telegram_id, chat_id)
    @github_acc = github_acc
    @telegram_id = telegram_id
    @chat_id = chat_id
    @repos = {}
  end
end
