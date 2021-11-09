require "rails_helper"

RSpec.describe Product, type: :model do
  describe "Associations" do
    it "belong to category" do
      is_expected.to belong_to(:category)
    end

    it "has many order_details" do
      is_expected.to have_many(:order_details).dependent(:destroy)
    end

    it "has many orders through order_details" do
      is_expected.to have_many(:orders).through(:order_details)
    end

    it "nested attributes category" do
      is_expected.to accept_nested_attributes_for(:category).allow_destroy(true)
    end
  end

  describe "scopes" do
    let!(:category_1){FactoryBot.create :category}
    let!(:product_1){FactoryBot.create :product, category_id: category_1.id}
    let!(:product_2){FactoryBot.create :product}
    let!(:product_3){FactoryBot.create :product, name: "tra dao"}
    context ".recent_products" do
      it "return product has sort DESC" do
        expect(Product.recent_products).to eq([product_3, product_2, product_1])
      end
    end
    context ".find_name" do
      it "search product by name" do
        expect(Product.find_name("tra dao")).to eq [product_3]
      end
    end
    context ".find_products_cart" do
      it "return product has id = 9" do
        expect(Product.find_products_cart(product_3.id)).to eq [product_3]
      end
      it "return product has id fail" do
        expect(Product.find_products_cart("")).to eq []
      end
    end
    context ".filter_category" do
      it "return product with category_id" do
        expect(Product.find_products_cart(category_1.id)).to eq [product_1]
      end
      it "return product with category_id fail" do
        expect(Product.find_products_cart("")).to eq []
      end
    end
  end

  describe "has one thumbnail" do
    context "with a valid thumbnail" do
      it { is_expected.to have_one(:thumbnail_attachment) }
    end
  end

  describe "has many images" do
    context "with a valid images" do
      it { is_expected.to have_many(:images_attachments) }
    end
  end

  describe "Enum" do
    it { should define_enum_for(:status).with_values([:disabled, :enabled]) }
  end

  describe "Delegate category" do
    it { should delegate_method(:name).to(:category).with_prefix }
  end

  describe "Validations" do
    context "field name" do
      it { is_expected.to validate_presence_of(:name) }

      it { is_expected.to validate_length_of(:name).is_at_least(5) }

      it { is_expected.to validate_length_of(:name).is_at_most(250) }
    end

    context "field price" do
      it { is_expected.to validate_presence_of(:price) }

      it { is_expected.to validate_numericality_of(:price) }

      it { should allow_value(Settings.init_number).for(:price) }

      it { should_not allow_value(Settings.price_fail).for(:price) }

    end

    context "field description" do
      it { is_expected.to validate_presence_of(:description) }

      it { is_expected.to validate_length_of(:description).is_at_least(5) }

      it { is_expected.to validate_length_of(:description).is_at_most(250) }
    end

    context "field quantity" do
      it { is_expected.to validate_presence_of(:quantity) }

      it { is_expected.to validate_numericality_of(:quantity).only_integer }

      it { should allow_value(Settings.init_number).for(:quantity) }

      it { should_not allow_value(Settings.price_fail).for(:quantity) }
    end

    # context "field images" do
    #   it { is_expected.to validate_content_type_of(:images).allowing("image/png", "image/jpg", "image/jpeg") }
    #   # it { is_expected.to allow_content_types("image/png", "image/jpg", "image/jpeg").for(:images) }
    # end
  end

  describe "method reject" do
    let!(:category_1) { FactoryBot.create :category}
    let!(:category_2) { FactoryBot.create :category}
    context "invalid" do
      it "name blank" do
        category_1.name.blank?
        is_expected.to_not be_valid
      end
      it "duplicate category" do
        category_1 = category_2
        is_expected.to_not be_valid
      end
    end
  end
end
