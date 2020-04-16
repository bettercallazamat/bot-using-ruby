# spec :bot_spec.rb
# rubocop:disable Layout/LineLength

require './lib/bot.rb'

RSpec.describe(Bot) do
  let(:bot) { Bot.new}
  describe '.initialize' do
    context 'when bot runs this method' do
      it 'creates instance of Bot class' do
        expect(bot.class).to eq Bot
      end
    end
  end
end

# rubocop:enable Layout/LineLength
