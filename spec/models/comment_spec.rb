require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
  end

  describe '#conversation_type' do
    it 'returns comment' do
      comment = build(:comment)
      expect(comment.conversation_type).to eq('comment')
    end
  end

  describe '#author' do
    it 'returns user display name' do
      user = create(:user, email_address: 'john.doe@example.com')
      comment = create(:comment, user: user)

      expect(comment.author).to eq('John doe')
    end
  end

  describe 'callbacks' do
    let(:project) { create(:project) }
    let(:comment) { build(:comment, project: project, user: project.user) }

    it 'broadcasts comment after creation' do
      expect(comment).to receive(:broadcast_comment)
      comment.save!
    end
  end
end
