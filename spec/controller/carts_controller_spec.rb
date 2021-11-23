require "rails_helper"
include SessionsHelper

RSpec.describe CartsController, type: :controller do
  let!(:product) { FactoryBot.create :product }
  describe "GET #index" do
    before do
      session[:cart] = {}
      session[:cart][product.id.to_s] = 5
      @carts = Product.find_products_cart(session[:cart].keys)
      get :index
    end

    it "assigns @carts" do
      expect(assigns(:carts)).to eq @carts
    end

    it "render template index" do
      expect(response).to render_template(:index)
    end
  end

  describe "POST #create" do
    context "when product exist" do
      before do
        session[:cart] = {}
        post :create, params: { product_id: product.id }
      end

      context "with quantity is not positive" do
        before do
          post :create, params: { product_id: product.id, quantity: -1 }
        end

        it "return quantity equal 1" do
          expect(session[:cart][product.id.to_s]).to eq(1)
        end
      end

      describe "with quantity is positive" do
        context "when product not exists in cart" do
          before do
            session[:cart] = {}
            post :create, params: { product_id: product.id, quantity: 1 }
          end

          it "return quantity" do
            expect(session[:cart][product.id.to_s]).to eq(1)
          end
        end

        context "when product already exists in cart" do
          context "when quantity > product.quantity" do
            before do
              session[:cart] = { product.id.to_s => 5 }
              post :create, params: { product_id: product.id, quantity: 6 }
            end

            it "return quantity = product.quantity" do
              expect(session[:cart][product.id.to_s]).to eq(10)
            end
          end

          context "when quantity <= product.quantity" do
            before do
              session[:cart] = { product.id.to_s => 5 }
              post :create, params: { product_id: product.id, quantity: 1 }
            end

            it "return quantity" do
              expect(session[:cart][product.id.to_s]).to eq(6)
            end
          end
        end
      end
    end

    context "when product not exist" do
      before do
        post :create, params: { product_id: -1 }
      end

      it "return flash danger" do
        expect(flash[:danger]).to eq I18n.t("show_product_fail")
      end

      it "redirect to root_path" do
        expect(response).to redirect_to root_url
      end
    end
  end

  describe "POST #destroy" do
    before do
      session[:cart] = {}
      session[:cart][product.id.to_s] = 5
      delete :destroy, params: { id: product.id }
      @carts = Product.find_products_cart(session[:cart].keys)
    end

    it "check deleted product" do
      expect(assigns(:carts)).to eq nil
    end

    it "redirect to carts_path" do
      expect(response).to redirect_to(carts_path)
    end
  end
end
