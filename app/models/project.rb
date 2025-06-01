class Project < ApplicationRecord
  belongs_to :user # project owner
  has_many :comments, dependent: :destroy
  has_many :status_changes, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :members, through: :project_memberships, source: :user

  validates :name, presence: true
  validates :status, presence: true

  # Get all conversation history items (comments and status changes) sorted by creation time
  def conversation_history
    (comments + status_changes).sort_by(&:created_at)
  end

  # Check if user can access this project (owner or member)
  def accessible_by?(user)
    self.user == user || members.include?(user)
  end

  # Get all users who have access to this project
  def all_users
    ([user] + members).uniq
  end

  # Update status and create a status change record
  def update_status!(new_status, changed_by)
    old_status = self.status
    return false if old_status == new_status

    ActiveRecord::Base.transaction do
      update!(status: new_status)
      status_changes.create!(
        from_status: old_status,
        to_status: new_status,
        changed_by: changed_by
      )
    end
    true
  end

  # Available status options
  def self.status_options
    [ "pending", "in_progress", "completed", "on_hold", "cancelled" ]
  end
end
