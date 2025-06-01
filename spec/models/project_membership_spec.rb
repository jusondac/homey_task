require 'rails_helper'

RSpec.describe ProjectMembership, type: :model do
  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:project_membership) }

    it { should validate_uniqueness_of(:user_id).scoped_to(:project_id) }
    it { should validate_presence_of(:role) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(member: 'member', admin: 'admin') }
  end

  describe 'uniqueness validation' do
    let(:project) { create(:project) }
    let(:user) { create(:user) }

    before do
      create(:project_membership, project: project, user: user)
    end

    it 'prevents duplicate memberships for same user and project' do
      duplicate_membership = build(:project_membership, project: project, user: user)

      expect(duplicate_membership).not_to be_valid
      expect(duplicate_membership.errors[:user_id]).to include('has already been taken')
    end

    it 'allows same user to be member of different projects' do
      other_project = create(:project)
      membership = build(:project_membership, project: other_project, user: user)

      expect(membership).to be_valid
    end

    it 'allows different users to be members of same project' do
      other_user = create(:user)
      membership = build(:project_membership, project: project, user: other_user)

      expect(membership).to be_valid
    end
  end
end
