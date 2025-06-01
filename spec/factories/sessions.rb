FactoryBot.define do
  factory :session do
    user_agent { "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" }
    ip_address { "127.0.0.1" }
    association :user
  end
end
