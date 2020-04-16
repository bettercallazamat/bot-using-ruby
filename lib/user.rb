class User
  attr_reader :github_acc, :repos
  attr_writer :repos

  def initialize(github_acc)
    @github_acc = github_acc
    @repos = {}
  end
end
