require "rails_helper"
include ProductsHelper

RSpec.describe StaticPagesController, type: :controller do
  describe "GET /home" do
    context "when products.size <=8 " do
      let!(:product_1) { FactoryBot.create :product, status: "enabled"}
      let!(:product_2) { FactoryBot.create :product, status: "enabled"}
      let!(:product_3) { FactoryBot.create :product}
      before do
        get :home
      end
      it "return products" do
        expect(assigns(:products)).to eq ([product_2, product_1])
      end
      it "render template home" do
        expect(response).to render_template :home
      end
    end

    context "when products.size > 8 " do
      let!(:products) { FactoryBot.create_list :product, 10}
      before do
        get :home
      end
      it "return size product = 8" do
        expect(:products.size).to eq (8)
      end
      it "render template home" do
        expect(response).to render_template :home
      end
    end
  end
end
