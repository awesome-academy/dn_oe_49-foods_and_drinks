require "rails_helper"

RSpec.describe Order, type: :model do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should have_many(:order_details).dependent(:destroy) }
    it { should have_many(:products).through(:order_details) }
  end

  describe "delegate" do
    it { should delegate_method(:name).to(:address).with_prefix(true) }
    it { should delegate_method(:name).to(:user).with_prefix(true) }
    it { should delegate_method(:email).to(:user).with_prefix(true) }
  end

  describe "enum" do
    it { should define_enum_for(:status).with_values(
      open: Settings.open,
      confirmed: Settings.confirmed,
      shipping: Settings.shipping,
      completed: Settings.completed,
      cancelled: Settings.cancelled,
      disclaim: Settings.disclaim)
    }
  end

  describe "scopes" do
    let!(:order_1) {FactoryBot.create :order}
    let!(:order_2) {FactoryBot.create :order}
    let!(:order_3) {FactoryBot.create :order}

    context "with recent_orders" do
      it "return orders with created_at sort DESC" do
        expect(Order.recent_orders).to eq [order_3, order_2, order_1]
      end
    end
  end
end
