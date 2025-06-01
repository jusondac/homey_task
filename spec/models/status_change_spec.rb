require 'rails_helper'

RSpec.describe StatusChange, type: :model do
  describe 'associations' do
    it { should belong_to(:project) }
  end

  describe 'validations' do
    it { should validate_presence_of(:to_status) }
    it { should validate_presence_of(:changed_by) }
  end

  describe '#conversation_type' do
    it 'returns status_change' do
      status_change = build(:status_change)
      expect(status_change.conversation_type).to eq('status_change')
    end
  end

  describe '#description' do
    context 'when from_status is present' do
      it 'returns status change description with from and to statuses' do
        status_change = build(:status_change, from_status: 'pending', to_status: 'in_progress')
        expect(status_change.description).to eq('Status changed from Pending to In progress')
      end
    end

    context 'when from_status is not present' do
      it 'returns status set description with only to status' do
        status_change = build(:status_change, from_status: nil, to_status: 'pending')
        expect(status_change.description).to eq('Status set to Pending')
      end
    end

    context 'when from_status is empty string' do
      it 'returns status set description' do
        status_change = build(:status_change, from_status: '', to_status: 'completed')
        expect(status_change.description).to eq('Status set to Completed')
      end
    end
  end
end
