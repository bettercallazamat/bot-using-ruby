# frozen_string_literal: true

# rubocop:disable Layout/LineLength
# rubocop:disable Style/Documentation
# rubocop:disable Style/GlobalVars

require 'rubygems'
require 'httparty'

class GitHubConnector
  include HTTParty
  base_uri 'https://api.github.com'

  def repos(username)
    obj = self.class.get("/users/#{username}/repos", ENV['BASIC_AUTH'])
    repos_array = []
    obj.each { |value| repos_array.push(value['name']) }
    repos_array
  end

  def pull_requests(username, repo)
    obj = self.class.get("/repos/#{username}/#{repo}/pulls", ENV['BASIC_AUTH'])
    pull_requests_array = []
    obj.each { |value| pull_requests_array.push(value['title']) }
    pull_requests_array
  end

  def comments_num(username, repo, num)
    obj = self.class.get("/repos/#{username}/#{repo}/issues/#{num}/comments", ENV['BASIC_AUTH'])
    obj.length
  end

  def pr_exists?(username, repo, num)
    obj = self.class.get("/repos/#{username}/#{repo}/issues/#{num}/comments", ENV['BASIC_AUTH'])
    if obj[0].nil?
      false
    else
      true
    end
  end
end

$github = GitHubConnector.new

# rubocop:enable Layout/LineLength
# rubocop:enable Style/Documentation
# rubocop:enable Style/GlobalVars
