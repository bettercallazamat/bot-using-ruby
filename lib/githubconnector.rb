require 'rubygems'
require 'httparty'

class GitHubConnector
  include HTTParty
  base_uri 'https://api.github.com'

  def initialize
    @options = {
      basic_auth: { 
        username: ENV['GITHUB_USERNAME'],
        password: ENV['GITHUB_PASSWORD']
      }
    }
  end

  def repos(username)
    obj = self.class.get("/users/#{username}/repos", @options)
    repos_array = []
    obj.each { |value| repos_array.push(value['name']) }
    repos_array
  end

  def pull_requests(username, repo)
    obj = self.class.get("/repos/#{username}/#{repo}/pulls", @options)
    pull_requests_array = []
    obj.each { |value| pull_requests_array.push(value['title']) }
    pull_requests_array
  end

  def comments_num(username, repo, num)
    obj = self.class.get("/repos/#{username}/#{repo}/issues/#{num}/comments", @options)
    obj.length
  end

  def pr_exists?(username, repo, num)
    obj = self.class.get("/repos/#{username}/#{repo}/issues/#{num}/comments", @options)
    if obj[0].nil?
      false
    else
      true
    end
  end
end
