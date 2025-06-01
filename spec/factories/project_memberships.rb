FactoryBot.define do
  factory :project_membership do
    role { "member" }
    association :project
    association :user

    trait :admin do
      role { "admin" }
    end
  end
end
