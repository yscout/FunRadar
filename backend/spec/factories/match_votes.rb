FactoryBot.define do
  factory :match_vote do
    association :invitation
    association :event
    match_id { "match_#{rand(1..10)}" }
    score { rand(1..5) }
  end
end

