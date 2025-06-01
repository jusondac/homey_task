require 'rails_helper'

RSpec.describe Session, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'factory' do
    it 'creates a valid session' do
      session = build(:session)
      expect(session).to be_valid
    end

    it 'creates session with user association' do
      session = create(:session)
      expect(session.user).to be_present
      expect(session.user).to be_a(User)
    end
  end
end
