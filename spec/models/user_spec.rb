require "rails_helper"

RSpec.describe User, type: :model do
  describe "Callback" do
    it { is_expected.to callback(:downcase_email).before(:save) }
  end

  describe "Associations" do
    it "has many addresses" do
      is_expected.to have_many(:addresses).dependent(:destroy)
    end

    it "has many orders" do
      is_expected.to have_many(:orders).dependent(:destroy)
    end
  end

  describe "Validations" do
    subject { FactoryBot.create :user }

    it "is valid with valid attributes" do
        is_expected.to be_valid
    end

    context "field name" do
      it { is_expected.to validate_presence_of(:name) }

      it { is_expected.to validate_length_of(:name).is_at_least(Settings.length.min_5) }

      it { is_expected.to validate_length_of(:name).is_at_most(Settings.length.max_100) }
    end

    context "field email" do
      it "when email nil" do
        expect(FactoryBot.build(:user, email: nil)).to_not be_valid
      end
      it "when email uniquess" do
        is_expected.to validate_uniqueness_of(:email).case_insensitive
      end
      it "when too short is invalid" do
        should_not allow_value("foo").for(:email)
      end

      it "when email valid" do
        should allow_value("foo@gmail.com").for(:email)
      end
    end

    context "field password" do
      it "when nil is invalid" do
        subject.password = nil
        is_expected.to_not be_valid
      end
    end
  end

  describe "methods" do
    let(:user){FactoryBot.create :user}

    context ".recent_orders" do
      let!(:order_1){FactoryBot.create :order, user_id: user.id}
      let!(:order_2){FactoryBot.create :order, user_id: user.id}

      it "return object ActiveRecord::Relation" do
        expect(user.all_orders).to be_an(ActiveRecord::Relation)
      end
    end
  end
end
