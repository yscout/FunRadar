FactoryBot.define do
  factory :preference do
    association :invitation
    available_times { ["Saturday 3:00 PM", "Sunday 10:00 AM", "Friday 7:00 PM"] }
    activities { ["Dinner", "Coffee", "Picnic"] }
    budget_min { 10 }
    budget_max { 50 }
    ideas { Faker::Lorem.sentence }
    submitted_at { Time.current }

    trait :low_budget do
      budget_min { 5 }
      budget_max { 20 }
    end

    trait :high_budget do
      budget_min { 50 }
      budget_max { 150 }
    end

    trait :flexible_schedule do
      available_times { ["Monday 6:00 PM", "Tuesday 6:00 PM", "Wednesday 6:00 PM", "Thursday 6:00 PM", "Friday 6:00 PM", "Saturday All Day", "Sunday All Day"] }
    end
  end
end

