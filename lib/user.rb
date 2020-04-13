class User
  # attr_accessor :github_username
  def initialize(telegram_id)
    @telegram_id = telegram_id
  end

  def auth(input)
    @github_username = input
  end

  def github_username
    @github_username
  end
end