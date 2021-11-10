FactoryBot.define do
  factory :address do
    name{Faker::Name.initials(number: 10)}
    address{Faker::Address.street_address}
    phone{Faker::PhoneNumber.phone_number}
    user_id{create(:user).id}
  end
end
