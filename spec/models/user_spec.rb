require "rails_helper"

RSpec.describe User, type: :model do
  describe "Associations" do
    it { should have_many(:addresses).dependent(:destroy) }
    it { should have_many(:orders).dependent(:destroy) }
  end

  describe "Validations" do
    subject { FactoryBot.create :user }

    it "is valid with valid attributes" do
        is_expected.to be_valid
    end

    context "with #name" do
      it { should validate_presence_of(:name) }
      it { should validate_length_of(:name).is_at_least(Settings.length.min_5) }
      it { should validate_length_of(:name).is_at_most(Settings.length.max_100) }
    end

    context "with #email" do
      it "when email nil" do
        expect(FactoryBot.build(:user, email: nil)).to_not be_valid
      end

      it "when email uniquess" do
        is_expected.to validate_uniqueness_of(:email).case_insensitive
      end

      it "when too short is invalid" do
        should_not allow_value("test").for(:email)
      end

      it "when email valid" do
        should allow_value("test@gmail.com").for(:email)
      end
    end

    context "with #password" do
      it "when nil is invalid" do
        subject.password = nil
        is_expected.to_not be_valid
      end
    end
  end

  describe "Methods" do
    let(:user){FactoryBot.create :user}

    context "with .recent_orders" do
      let!(:order_1){FactoryBot.create :order, user_id: user.id}
      let!(:order_2){FactoryBot.create :order, user_id: user.id}

      it "return orders with created_at sort DESC" do
        expect(Order.recent_orders).to eq [order_2, order_1]
      end
    end
  end
end
