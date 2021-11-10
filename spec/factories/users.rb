FactoryBot.define do
  factory :user do
    name{Faker::Name.name_with_middle}
    email{Faker::Internet.email.downcase}
    password{"Hello@1234"}
    password_confirmation{"Hello@1234"}
  end
end
