FactoryBot.define do
  factory :activity_suggestion do
    association :event
    payload do
      [
        {
          "id" => 1,
          "title" => "Jazz Picnic",
          "compatibility" => 95,
          "image" => "https://images.unsplash.com/photo-1603543900250-275a638755a9",
          "location" => "Central Park",
          "price" => "$15/person",
          "time" => "Saturday, 3:00 PM",
          "emoji" => "🎶",
          "votes" => 4,
          "description" => "Live jazz band with picnic setup"
        },
        {
          "id" => 2,
          "title" => "Rooftop Dinner",
          "compatibility" => 88,
          "image" => "https://images.unsplash.com/photo-1742002661612-771125d0c050",
          "location" => "Downtown Skybar",
          "price" => "$45/person",
          "time" => "Friday, 7:00 PM",
          "emoji" => "🍽️",
          "votes" => 4,
          "description" => "Italian cuisine with city views"
        }
      ]
    end
  end
end

