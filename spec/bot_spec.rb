# spec :bot_spec.rb

require './lib/bot.rb'

RSpec.describe(Bot) do
  let(:bot) { Bot.new }
  describe '.initialize' do
    context 'when bot runs this method' do
      it 'creates instance of Bot class' do
        expect(bot.class).to eq Bot
      end
    end
  end

  describe '.text_reply' do
    context 'when bot runs this method' do
      it 'sends message to telegram user' do
        expect(bot.text_reply(bot, message, content)).to eq 123
      end
    end
  end
end
