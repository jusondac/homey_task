FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    sequence(:description) { |n| "Description for project #{n}" }
    status { "pending" }
    association :user

    trait :in_progress do
      status { "in_progress" }
    end

    trait :completed do
      status { "completed" }
    end

    trait :on_hold do
      status { "on_hold" }
    end

    trait :cancelled do
      status { "cancelled" }
    end

    trait :with_comments do
      after(:create) do |project|
        create_list(:comment, 3, project: project, user: project.user)
      end
    end

    trait :with_members do
      after(:create) do |project|
        users = create_list(:user, 2)
        users.each do |user|
          create(:project_membership, project: project, user: user)
        end
      end
    end

    trait :with_status_changes do
      after(:create) do |project|
        create(:status_change, project: project, from_status: "pending", to_status: "in_progress", changed_by: project.user.display_name)
      end
    end
  end
end
