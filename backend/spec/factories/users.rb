FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "#{Faker::Name.first_name}#{n}" }
    location_permission { false }
    location_latitude { nil }
    location_longitude { nil }

    trait :with_location do
      location_permission { true }
      location_latitude { Faker::Address.latitude }
      location_longitude { Faker::Address.longitude }
    end

    trait :with_events do
      after(:create) do |user|
        create_list(:event, 2, organizer: user)
      end
    end
  end
end

