FactoryBot.define do
  factory :invitation do
    association :event
    invitee { nil }  # Optional association - can be set explicitly in tests
    sequence(:invitee_name) { |n| "#{Faker::Name.first_name}#{n}" }
    access_token { SecureRandom.uuid }
    role { :participant }
    status { :pending }
    responded_at { nil }

    trait :organizer do
      role { :organizer }
    end

    trait :participant do
      role { :participant }
    end

    trait :submitted do
      status { :submitted }
      responded_at { Time.current }
    end

    trait :with_preference do
      after(:create) do |invitation|
        create(:preference, invitation: invitation)
      end
    end
  end
end

