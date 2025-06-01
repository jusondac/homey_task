require 'rails_helper'

RSpec.describe Current, type: :model do
  describe 'attributes' do
    it 'has session attribute' do
      expect(Current).to respond_to(:session)
      expect(Current).to respond_to(:session=)
    end
  end

  describe 'delegation' do
    let(:user) { create(:user) }
    let(:session) { create(:session, user: user) }

    it 'delegates user to session' do
      Current.session = session
      expect(Current.user).to eq(user)
    end

    it 'returns nil when session is nil' do
      Current.session = nil
      expect(Current.user).to be_nil
    end

    it 'handles nil session gracefully' do
      Current.session = nil
      expect { Current.user }.not_to raise_error
      expect(Current.user).to be_nil
    end
  end

  describe 'current attributes behavior' do
    let(:user) { create(:user) }
    let(:session) { create(:session, user: user) }

    after do
      Current.reset
    end

    it 'maintains session across the request' do
      Current.session = session
      expect(Current.session).to eq(session)
      expect(Current.user).to eq(user)
    end

    it 'can be reset' do
      Current.session = session
      Current.reset
      expect(Current.session).to be_nil
      expect(Current.user).to be_nil
    end
  end
end
