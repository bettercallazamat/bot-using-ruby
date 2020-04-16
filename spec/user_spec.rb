# spec :user_spec.rb
# rubocop:disable Layout/LineLength

require './lib/user.rb'

RSpec.describe(User) do
  let(:user) { User.new('bettercallazamat') }
  describe '.initialize' do
    context 'when bot runs this method' do
      it 'creates instance of User class' do
        expect(user.class).to eq User
      end
    end
  end
end

# rubocop:enable Layout/LineLength
