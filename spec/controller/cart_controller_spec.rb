require "rails_helper"
include SessionsHelper

RSpec.describe CartsController, type: :controller do
  let!(:product) { FactoryBot.create :product }
  describe "GET #index" do
    before do
      session[:cart] = {}
      session[:cart][product.id.to_s] = 3
      @carts = Product.find_products_cart(session[:cart].keys)
      get :index
    end

    it "assigns @carts" do
      expect(assigns(:carts)).to eq @carts
    end

    it "renders the index template" do
      expect(response).to render_template :index
    end
  end

  describe "DELETE #destroy" do
    before do
      session[:cart] = {}
      session[:cart][product.id.to_s] = 3
      delete :destroy, params: {id: product.id}
    end

    it "check key in carts after remove" do
      expect(session[:cart].key?(product.id.to_s)).to eq false
    end

    it "redirect to carts path" do
      expect(response).to redirect_to carts_path
    end
  end

  describe "POST #create" do
    context "when product exist " do
      before do
        post :create, params: {product_id: product.id}
      end

      it "product exist" do
        expect(assigns(:product)).to eq product
      end

      context "when quantity < 1 " do
        before do
          session[:cart] = {}
          post :create, params: {product_id: product.id, quantity: -1}
        end

        it "return quantity = 1" do
          expect(session[:cart][product.id.to_s]).to eq(1)
        end
      end

      context "when quantity > 0 " do
        context "when product not exist in cart" do
          before do
            session[:cart] = {}
            post :create, params: {product_id: product.id, quantity: 2}
          end

          it "return quantity" do
            expect(session[:cart][product.id.to_s]).to eq(2)
          end
        end

        context "when product exist in cart" do
          context "when quantity <= product.quantity" do
            before do
              session[:cart] = {product.id.to_s => 2}
              post :create, params: {product_id: product.id, quantity: 2}
            end

            it "return quantity if product duplicate" do
              expect(session[:cart][product.id.to_s]).to eq(4)
            end
          end

          context "when quantity > product.quantity" do
            before do
              session[:cart] = {product.id.to_s => 2}
              post :create, params: {product_id: product.id, quantity: 6}
            end

            it "return quantity if product duplicate" do
              expect(session[:cart][product.id.to_s]).to eq(product.quantity)
            end
          end
        end
      end
    end
    context "when product not exist " do
      before do
        post :create, params: {product_id: -1}
      end

      it "display flash warning when product not found" do
        expect(flash[:danger]).to eq I18n.t("show_product_fail")
      end

      it "redirect root page when product not found" do
        expect(response).to redirect_to root_path
      end
    end
  end
end
