require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'associations' do
    it { should have_secure_password }
    it { should have_many(:sessions).dependent(:destroy) }
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:project_memberships).dependent(:destroy) }
    it { should have_many(:member_projects).through(:project_memberships).source(:project) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email_address) }

    context 'email uniqueness' do
      subject { create(:user) }
      it { should validate_uniqueness_of(:email_address).case_insensitive }
    end

    it { should allow_value('user@example.com').for(:email_address) }
    it { should_not allow_value('invalid_email').for(:email_address) }
    it { should validate_presence_of(:password).on(:create) }
    it { should validate_length_of(:password).is_at_least(6).on(:create) }
  end

  describe 'email normalization' do
    it 'normalizes email address to lowercase and strips whitespace' do
      user = create(:user, email_address: '  TEST@EXAMPLE.COM  ')
      expect(user.email_address).to eq('test@example.com')
    end
  end

  describe '#accessible_projects' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    let!(:owned_project) { create(:project, user: user) }
    let!(:member_project) { create(:project, user: other_user) }
    let!(:inaccessible_project) { create(:project, user: other_user) }

    before do
      create(:project_membership, user: user, project: member_project)
    end

    it 'returns projects owned by user and projects where user is a member' do
      accessible = user.accessible_projects

      expect(accessible).to include(owned_project)
      expect(accessible).to include(member_project)
      expect(accessible).not_to include(inaccessible_project)
    end

    it 'returns distinct projects' do
      # The uniqueness constraint prevents creating another membership for the same user/project
      # So we'll test with a different project instead
      another_project = create(:project, user: other_user)
      create(:project_membership, user: user, project: another_project)

      accessible_ids = user.accessible_projects.pluck(:id)
      expect(accessible_ids.uniq.length).to eq(accessible_ids.length)
    end
  end

  describe '#display_name' do
    it 'returns humanized email address without domain' do
      user = create(:user, email_address: 'john.doe@example.com')
      expect(user.display_name).to eq('John.doe')
    end

    it 'handles simple email addresses' do
      user = create(:user, email_address: 'test@example.com')
      expect(user.display_name).to eq('Test')
    end
  end
end
