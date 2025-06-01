class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :projects, dependent: :destroy # projects owned by user
  has_many :comments, dependent: :destroy
  has_many :project_memberships, dependent: :destroy
  has_many :member_projects, through: :project_memberships, source: :project

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  # Get all projects user has access to (owned + member)
  def accessible_projects
    Project.joins("LEFT JOIN project_memberships ON projects.id = project_memberships.project_id")
           .where("projects.user_id = ? OR project_memberships.user_id = ?", id, id)
           .distinct
  end

  def display_name
    email_address.split("@").first.humanize
  end
end
