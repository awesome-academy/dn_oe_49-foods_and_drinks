require "rails_helper"

RSpec.describe Product, type: :model do
  describe "Associations" do
    it { is_expected.to belong_to(:category) }
    it { is_expected.to have_many(:order_details).dependent(:destroy) }
    it { is_expected.to have_many(:orders).through(:order_details) }
    it { is_expected.to have_one_attached :thumbnail }
    it { is_expected.to have_many_attached :images }
    it { is_expected.to accept_nested_attributes_for(:category) }
  end

  describe "Scopes" do
    let!(:category_1) {FactoryBot.create :category}
    let!(:product_1) {FactoryBot.create :product, category_id: category_1.id}
    let!(:product_2) {FactoryBot.create :product}
    let!(:product_3) {FactoryBot.create :product}

    context "with find_name" do
      it "return products by name" do
        expect(Product.find_name(product_1.name)).to eq [product_1]
      end
    end

    context "with recent_products" do
      it "return products with created_at sort DESC" do
        expect(Product.recent_products).to eq [product_3, product_2, product_1]
      end
    end

    context "with find_products_cart" do
      it "return product by id" do
        expect(Product.find_products_cart(product_1.id)).to eq [product_1]
      end
    end

    context "with filter_category" do
      it "return products by category" do
        expect(Product.filter_category(category_1.id)).to eq [product_1]
      end
    end
  end

  describe "enum" do
    it { should define_enum_for(:status).with_values([:disabled, :enabled]) }
  end

  describe "delegate" do
    it { should delegate_method(:name).to(:category).with_prefix(true) }
  end

  describe "Validates" do
    subject {FactoryBot.create :product}

    context "#name" do
      it { should validate_presence_of(:name) }

      it { should validate_length_of(:name).is_at_least(Settings.length.min_5) }

      it { should validate_length_of(:name).is_at_most(Settings.length.max_250) }
    end

    context "#price" do
      it { should validate_presence_of(:price) }

      it { should validate_numericality_of(:price)}

      it { should allow_value(1.1).for(:price)}

      it { should_not allow_value(Settings.length.digit_negative_1).for(:price) }
    end

    context "#description" do
      it { should validate_presence_of(:description) }

      it { should validate_length_of(:description).is_at_least(Settings.length.min_5) }

      it { should validate_length_of(:description).is_at_most(Settings.length.max_250) }
    end

    context "#quantity" do
      it { should validate_presence_of(:quantity) }

      it { should validate_numericality_of(:quantity)}

      it { should_not allow_value(1.1).for(:quantity)}

      it { should_not allow_value(Settings.length.digit_negative_1).for(:quantity) }
    end
  end
end
