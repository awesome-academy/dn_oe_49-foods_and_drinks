# Fake accounts and address
10.times do |n|
  name = Faker::Name.unique.name
  email = "example-#{rand(252...4350)}@test-example.com"
  password = "password123"
  phone = Faker::PhoneNumber.phone_number
  address = Faker::Address.full_address
  u = User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password,
                   status: true,
                   role: 0)
  u.addresses.create!(name: name,
                      phone: phone,
                      address: address)
end

# Fake category
7.times do |n|
  name = Faker::Food.ingredient
  description = Faker::Food.description
  Category.create!(name: name, description: description)
end

# Fake products
130.times do |n|
  categories = Category.order(:created_at).sample(1)
  name = Faker::Food.fruits
  price = 200000
  description = Faker::Food.description
  quantity = rand(0..10)
  status = rand(0..1)
  categories.each do |category|
    category.products.create!(name: name,
                              price: price,
                              description: description,
                              quantity: quantity,
                              status: status)
  end
end

# Fake address and set is_default: true
User.all.each do |user|
  2.times do
  user.addresses.create(
    name: Faker::Name.unique.name,
    phone: Faker::PhoneNumber.phone_number,
    address: Faker::Address.full_address)
  end
  user.addresses.last.update_column :is_default, true
end

# Fake orders
User.all.sample(1).each do |user|
  address1 = user.addresses.sample(1)
  product = Product.last
  order = user.orders.build(
    name: address1[0].name,
    phone: address1[0].phone,
    address: address1[0].address,
    total_price: product.price,
    address_id: address1[0].id)
  order.order_details.build(
    quantity: 2,
    price: product.price,
    product_id: product.id)
  order.save
end

phone = Faker::PhoneNumber.phone_number
address = Faker::Address.full_address
user = User.create!(name: "Admin",
                   email: "admintest@gmail.com",
                   password: "123456789",
                   password_confirmation: "123456789",
                   status: true,
                   role: 1)
user.addresses.create!(name: user.name,
                       phone: phone,
                       address: address)
