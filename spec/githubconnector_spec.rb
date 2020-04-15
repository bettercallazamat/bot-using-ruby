# spec :githubconnector_spec.rb
# rubocop:disable Layout/LineLength

require './lib/githubconnector.rb'

RSpec.describe(GitHubConnector) do
  let(:github) { GitHubConnector.new }
  describe '.repos' do
    context 'when bot runs this method' do
      it 'returns array of repositories in GitHub for specific user' do
        expect(github.repos('bettercallazamat')).to eq %w[apple-website-old-version bot-using-ruby design-teardown-project enumerable-methods-ruby google-homepage google-searchpage microverse-collaborative-project microverse-stanley-azamat newsweek-using-bootstrap NYT-article-page online-shop-website tic-tac-toe-game-ruby]
      end
    end
  end

  describe '.pull_requests' do
    context 'when bot runs this method' do
      it 'returns array of pull request for specific repository' do
        expect(github.pull_requests('bettercallazamat', 'bot-using-ruby')).to eq ['PR to test telegram bot']
      end
    end
  end

  describe '.comments_num' do
    context 'when bot runs this method' do
      it 'return number of comments inside specific pull request' do
        expect(github.comments_num('bettercallazamat', 'bot-using-ruby', 1)).to eq 8
      end
    end
  end

  describe 'pr_exists?' do
    context 'when bot runs this method' do
      it 'returns true if such pull request with given number exist' do
        expect(github.pr_exists?('bettercallazamat', 'bot-using-ruby', 1)).to eq true
      end

      it 'returns true if such pull request with given number exist' do
        expect(github.pr_exists?('bettercallazamat', 'bot-using-ruby', 5)).to eq false
      end
    end
  end
end

# rubocop:enable Layout/LineLength
