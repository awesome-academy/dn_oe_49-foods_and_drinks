require "rails_helper"

RSpec.describe Order, type: :model do
  describe "Associations" do
    it "belong to user" do
      is_expected.to belong_to(:user)
    end

    it "has many order_details" do
      is_expected.to have_many(:order_details).dependent(:destroy)
    end

    it "has many products through order_details" do
      is_expected.to have_many(:products).through(:order_details)
    end
  end

  describe "Delegates" do
    context "name_address" do
      it { should delegate_method(:name).to(:address).with_prefix(true) }
    end

    context "name_user and email_user" do
      it { should delegate_method(:name).to(:user).with_prefix(true) }
      it { should delegate_method(:email).to(:user).with_prefix(true) }
    end
  end

  describe "Enums" do
    it "define status in enum"do
      should define_enum_for(:status).with_values(
        open: Settings.open,
        confirmed: Settings.confirmed,
        shipping: Settings.shipping,
        completed: Settings.completed,
        cancelled: Settings.cancelled,
        disclaim: Settings.disclaim)
    end
  end

  describe "Scopes" do
    let!(:order_1){FactoryBot.create :order}
    let!(:order_2){FactoryBot.create :order}
    context ".recent_orders" do
      it "return orders has sort DESC" do
        expect(Order.all.recent_orders).to eq ([order_2, order_1])
      end
    end
  end
end
