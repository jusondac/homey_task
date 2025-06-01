class StatusChange < ApplicationRecord
  belongs_to :project

  validates :to_status, presence: true
  validates :changed_by, presence: true

  def conversation_type
    "status_change"
  end

  def description
    if from_status.present?
      "Status changed from #{from_status.humanize} to #{to_status.humanize}"
    else
      "Status set to #{to_status.humanize}"
    end
  end
end
