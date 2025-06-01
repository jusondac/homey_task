require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:status_changes).dependent(:destroy) }
    it { should have_many(:project_memberships).dependent(:destroy) }
    it { should have_many(:members).through(:project_memberships).source(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status) }
  end

  describe '#conversation_history' do
    let(:project) { create(:project) }
    let(:user) { project.user }

    let!(:comment1) { create(:comment, project: project, user: user, created_at: 2.hours.ago) }
    let!(:status_change1) { create(:status_change, project: project, created_at: 1.hour.ago) }
    let!(:comment2) { create(:comment, project: project, user: user, created_at: 30.minutes.ago) }

    it 'returns comments and status changes sorted by creation time' do
      history = project.conversation_history

      expect(history).to eq([ comment1, status_change1, comment2 ])
    end

    it 'includes comments and status changes' do
      history = project.conversation_history

      expect(history).to include(comment1)
      expect(history).to include(comment2)
      expect(history).to include(status_change1)
    end

    it 'filters out items without created_at' do
      # This shouldn't happen in normal circumstances, but let's test defensive coding
      allow(comment1).to receive(:created_at).and_return(nil)

      history = project.conversation_history

      expect(history).not_to include(comment1)
      expect(history).to include(status_change1)
      expect(history).to include(comment2)
    end
  end

  describe '#accessible_by?' do
    let(:owner) { create(:user) }
    let(:member) { create(:user) }
    let(:non_member) { create(:user) }
    let(:project) { create(:project, user: owner) }

    before do
      create(:project_membership, user: member, project: project)
    end

    it 'returns true for project owner' do
      expect(project.accessible_by?(owner)).to be true
    end

    it 'returns true for project member' do
      expect(project.accessible_by?(member)).to be true
    end

    it 'returns false for non-member' do
      expect(project.accessible_by?(non_member)).to be false
    end
  end

  describe '#all_users' do
    let(:owner) { create(:user) }
    let(:member1) { create(:user) }
    let(:member2) { create(:user) }
    let(:project) { create(:project, user: owner) }

    before do
      create(:project_membership, user: member1, project: project)
      create(:project_membership, user: member2, project: project)
    end

    it 'returns owner and all members' do
      users = project.all_users

      expect(users).to include(owner)
      expect(users).to include(member1)
      expect(users).to include(member2)
      expect(users.size).to eq(3)
    end

    it 'returns unique users' do
      # Ensure no duplicates even if owner is also a member
      create(:project_membership, user: owner, project: project)

      users = project.all_users
      expect(users.count(owner)).to eq(1)
    end
  end

  describe '#update_status!' do
    let(:project) { create(:project, status: 'pending') }
    let(:user) { project.user }

    it 'updates status and creates status change record' do
      expect {
        result = project.update_status!('in_progress', user.display_name)
        expect(result).to be true
      }.to change { project.reload.status }.from('pending').to('in_progress')
        .and change { project.status_changes.count }.by(1)

      status_change = project.status_changes.last
      expect(status_change.from_status).to eq('pending')
      expect(status_change.to_status).to eq('in_progress')
      expect(status_change.changed_by).to eq(user.display_name)
    end

    it 'returns false when status is the same' do
      result = project.update_status!('pending', user.display_name)

      expect(result).to be false
      expect(project.status_changes.count).to eq(0)
    end

    it 'creates status change record in a transaction' do
      allow(project).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(project))

      expect {
        project.update_status!('in_progress', user.display_name)
      }.to raise_error(ActiveRecord::RecordInvalid)
        .and change { project.status_changes.count }.by(0)
    end
  end

  describe '.status_options' do
    it 'returns available status options' do
      expected_statuses = [ 'pending', 'in_progress', 'completed', 'on_hold', 'cancelled' ]
      expect(Project.status_options).to eq(expected_statuses)
    end
  end
end
