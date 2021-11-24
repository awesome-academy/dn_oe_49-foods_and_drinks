require "rails_helper"
include SessionsHelper

RSpec.describe OrdersController, type: :controller do
  let(:user) {FactoryBot.create :user}

  describe "GET #index" do
    context "when user logged in" do
      let!(:order) {FactoryBot.create :order}
      before do
        log_in order.user
        @orders = order.user.all_orders
        get :index, params: {user_id: order.user.id}
      end

      it "assigns @orders" do
        expect(assigns(:orders)).to eq @orders
      end

      it "render template index" do
        expect(response).to render_template(:index)
      end
    end

    context "when user unlogged" do
      before do
        get :index, params: {user_id: user.id}
      end

      it "return flash danger" do
        expect(flash[:danger]).to eq I18n.t("log_in.please_log_in")
      end

      it "redirect to login_url" do
        expect(response).to redirect_to login_url
      end
    end
  end

  describe "GET #new" do
    before do
      log_in user
      session[:cart] = {}
      get :new, params: {user_id: user.id}
    end

    context "when cart empty" do
      it "return flash danger" do
        expect(flash[:danger]).to eq I18n.t("cart_empty")
      end

      it "redirect to root_path" do
        expect(response).to redirect_to root_path
      end
    end

    context "when cart exist products" do
      let!(:product) {FactoryBot.create :product}
      before do
        session[:cart][product.id.to_s] = 5
        @carts = Product.find_products_cart(session[:cart].keys)
        get :new
      end

      it "assigns @carts" do
        expect(assigns(:carts)).to eq @carts
      end

      it "render template new" do
        expect(response).to render_template(:new)
      end
    end
  end

  describe "POST #create" do
    let!(:product) {FactoryBot.create :product}
    before do
      log_in user
      session[:cart] = {}
    end

    context "when user selects available address" do
      let!(:address) {FactoryBot.create :address}
      before do
        session[:cart][product.id.to_s] = 5
        @carts = Product.find_products_cart(session[:cart].keys)
        post :create, params: {
          user_id: user.id,
          address_id: address.id
        }
      end

      it "return flash success" do
        expect(flash[:success]).to eq I18n.t("orders.order_success")
      end

      it "redirect to user_orders_path" do
        expect(response).to redirect_to user_orders_path(user)
      end
    end

    context "when the user adds a new address" do
      before do
        session[:cart][product.id.to_s] = 5
        @carts = Product.find_products_cart(session[:cart].keys)
        post :create, params: {
          user_id: user.id,
          address: "Nguyen Van A_11 Nguyen Van Linh_0339019222"
        }
      end

      it "return flash success" do
        expect(flash[:success]).to eq I18n.t("orders.order_success")
      end

      it "redirect to user_orders_path" do
        expect(response).to redirect_to user_orders_path(user)
      end
    end

    # context "when save database fail" do
    #   before do
    #     session[:cart][product.id.to_s] = 5
    #     @carts = Product.find_products_cart(session[:cart].keys)
    #     post :create, params: {
    #       user_id: user.id,
    #       address: "kim_11 Nguyen Van Linh_123"
    #     }
    #   end

    #   it "return flash danger" do
    #     expect(flash(:danger)).to eq I18n.t("orders.order_fail")
    #   end

    #   it "redirect to" do
    #     expect(response).to redirect_to user_orders_path(user)
    #   end
    # end
  end

  describe "GET #show" do
    let!(:order) {FactoryBot.create :order, user_id: user.id}
    before do
      log_in order.user
    end

    context "when order exist" do
      let!(:product) {FactoryBot.create :product}
      let!(:order_detail) {
        FactoryBot.create :order_detail,
        order_id: order.id,
        product_id: product.id
      }

      before do
        @order = user.orders.find_by id: order.id
        @order_details = order.order_details.includes(:product)
        get :show, params: {user_id: order.user.id, id: order.id}
      end

      it "assigns @order" do
        expect(assigns(:order)).to eq @order
      end

      it "assigns @order_details" do
        expect(assigns(:order_details)).to eq @order_details
      end

      it "renders template show" do
        expect(response).to render_template :show
      end
    end

    context "when order not exist" do
      before do
        get :show, params: {
          user_id: order.user.id,
          id: Settings.length.digit_negative_1
        }
      end

      it "redirect to root_url" do
        expect(response).to redirect_to root_url
      end

      it "return flash danger" do
        expect(flash[:danger]).to eq I18n.t("orders.no_order")
      end
    end
  end

  describe "PUT #cancel" do
    let!(:order) {FactoryBot.create :order, status: :open, user_id: user.id}

    before do
      log_in order.user
    end

    context "when order with status is open" do
      before do
        put :cancel, params: {user_id: order.user.id, id: order.id }
      end

      it "return flash success" do
        expect(flash[:success]).to eq I18n.t("orders.order_changed")
      end

      it "redirect to user_order" do
        expect(response).to redirect_to user_order_path
      end
    end

    context "when order with status not open" do
      before do
        order.cancelled!
        put :cancel, params: {user_id: order.user.id, id: order.id }
      end

      it "return flash danger" do
        expect(flash[:danger]).to eq I18n.t("orders.update_fail")
      end

      it "redirect to root_url" do
        expect(response).to redirect_to user_order_path
      end
    end
  end
end
