FactoryBot.define do
  factory :category do
    name{Faker::Food.ingredient}
    description{Faker::Food.description}
  end
end
