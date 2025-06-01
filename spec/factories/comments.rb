FactoryBot.define do
  factory :comment do
    sequence(:content) { |n| "This is comment #{n} content" }
    association :project
    association :user

    trait :long_content do
      content { "This is a very long comment that contains multiple sentences and provides detailed feedback about the project. It might include suggestions, concerns, or updates about the project progress." }
    end
  end
end
