FactoryBot.define do
  factory :order_detail do
    quantity{4}
    price{1000}
    order_id{create(:order).id}
    product_id{create(:product).id}
  end
end
