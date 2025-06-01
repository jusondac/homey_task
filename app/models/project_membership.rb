class ProjectMembership < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :user_id, uniqueness: { scope: :project_id }
  validates :role, presence: true

  enum :role, { member: "member", admin: "admin" }
end
