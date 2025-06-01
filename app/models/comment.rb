class Comment < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :content, presence: true

  after_create_commit :broadcast_comment

  def conversation_type
    "comment"
  end

  def author
    user.display_name
  end

  private

  def broadcast_comment
    broadcast_prepend_to "project_#{project.id}_comments",
                        target: "comments",
                        partial: "comments/comment",
                        locals: { comment: self }
  end
end
