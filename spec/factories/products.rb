FactoryBot.define do
  factory :product do
    name { Faker::Food.fruits }
    price { 200000 }
    description {Faker::Food.description}
    quantity { 5 }
    status { 1 }
    category_id {create(:category).id}
  end
end