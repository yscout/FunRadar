FactoryBot.define do
  factory :event do
    association :organizer, factory: :user
    sequence(:title) { |n| "#{Faker::Lorem.words(number: 2).join(' ')} #{n}" }
    notes { Faker::Lorem.sentence }
    share_token { SecureRandom.uuid }
    status { :collecting }

    trait :pending_ai do
      status { :pending_ai }
    end

    trait :ready do
      status { :ready }
      ai_generated_at { Time.current }
    end

    trait :with_invitations do
      after(:create) do |event|
        create(:invitation, event: event, invitee_name: event.organizer.name, role: :organizer)
        create_list(:invitation, 3, event: event, role: :participant)
      end
    end

    trait :with_submitted_preferences do
      after(:create) do |event|
        organizer_invitation = create(:invitation, event: event, invitee_name: event.organizer.name, role: :organizer, invitee: event.organizer)
        create(:preference, invitation: organizer_invitation)
        organizer_invitation.reload  # Ensure callback has completed
        
        3.times do
          invitation = create(:invitation, event: event, role: :participant)
          create(:preference, invitation: invitation)
          invitation.reload  # Ensure callback has completed
        end
      end
    end
  end
end

