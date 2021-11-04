FactoryBot.define do
  factory :order do
    name { Faker::Name.name }
    address { Faker::Address.full_address }
    phone { Faker::PhoneNumber.phone_number }
    total_price { 300 }
    user_id { create(:user).id }
    address_id { create(:address).id }
  end
end
