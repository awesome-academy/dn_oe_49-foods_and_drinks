FactoryBot.define do
  factory :order do
    total_price{100000}
    name{Faker::Name.initials(number: 10)}
    address{Faker::Address.street_address}
    phone{Faker::PhoneNumber.phone_number}
    address_id{create(:address).id}
    user_id{create(:user).id}
  end
end
