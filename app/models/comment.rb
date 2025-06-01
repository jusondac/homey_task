class Comment < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :content, presence: true

  def conversation_type
    "comment"
  end

  def author
    user.email_address
  end
end
