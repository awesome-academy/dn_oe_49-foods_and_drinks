FactoryBot.define do
  factory :product do
    name { Faker::Name.name  }
    price { 200000 }
    description {Faker::Food.description}
    quantity { 5 }
    category_id {create(:category).id}
    trait :thumbnail do
      thumbnail { FilesTestHelper.png }
    end
  end
end
