FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_projects do
      after(:create) do |user|
        create_list(:project, 3, user: user)
      end
    end

    trait :with_session do
      after(:create) do |user|
        create(:session, user: user)
      end
    end
  end
end
