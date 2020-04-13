require 'rubygems'
require 'httparty' 

class GitHubConnector
  include HTTParty
  base_uri 'https://api.github.com'

  def repos
    obj = self.class.get("/users/#{$username}/repos")
    repos_array = []
    obj.each { |value| repos_array.push(value['name']) }
    repos_array
  end

  def pull_requests(repo)
    obj = self.class.get("/repos/#{$username}/#{repo}/pulls")
    pull_requests_array = []
    obj.each { |value| pull_requests_array.push(value['title']) }
    pull_requests_array
  end

  def comments_num(repo, num)
    obj = self.class.get("/repos/#{$username}/#{repo}/issues/#{num}/comments")
    obj.length
  end
end
