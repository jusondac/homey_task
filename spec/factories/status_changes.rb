FactoryBot.define do
  factory :status_change do
    from_status { "pending" }
    to_status { "in_progress" }
    sequence(:changed_by) { |n| "User #{n}" }
    association :project
  end
end
