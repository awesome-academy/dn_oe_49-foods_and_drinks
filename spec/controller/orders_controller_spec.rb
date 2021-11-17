require "rails_helper"
include SessionsHelper

RSpec.describe OrdersController, type: :controller do
  let(:user) {FactoryBot.create :user}

  describe "GET #index" do
    context "when user loggin" do
      let!(:order) {FactoryBot.create :order}
      before do
        log_in order.user
        @orders = order.user.all_orders
        get :index, params: {user_id: order.user.id}
      end

      it "assigns @orders" do
        expect(assigns(:orders)).to eq @orders
      end
      it "redirect to the root_url" do
        expect(response).to render_template :index
      end
    end

    context "when user not login" do
      before do
        get :index, params: {user_id: user.id}
      end

      it "redirect to the root_url" do
        expect(subject).to redirect_to login_url
      end
    end
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
          id: Settings.option_fail
        }
      end

      it "redirect to root_url" do
        expect(response).to redirect_to root_url
      end
      it "display flash danger" do
        expect(flash[:danger]).to eq I18n.t("orders.no_order")
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
      it "redirect to root_url" do
        expect(response).to redirect_to root_path
      end
      it "display flash danger" do
        expect(flash[:danger]).to eq I18n.t("cart_empty")
      end
    end

    context "when cart any item" do
      let!(:product) {FactoryBot.create :product}
      before do
        session_params = { product.id.to_s => Settings.option_1 }
        session[:cart] = session_params
        get :new, params: { user_id: user.id, session: session_params }
      end

      it "assigns @carts" do
        @carts = Product.find_products_cart(session[:cart].keys)
        expect(assigns(:carts)).to eq @carts
      end
      it "renders template new" do
        expect(response).to render_template :new
      end
    end
  end

  describe "PUT #cancel" do
    let!(:order) {FactoryBot.create :order, status: :open, user_id: user.id}
    before do
      log_in order.user
    end

    context "when order status open" do
      before do
        put :cancel, params: {user_id: order.user.id, id: order.id }
      end
      it "display flash success" do
        expect(flash[:success]).to eq I18n.t("orders.order_changed")
      end
      it "redirect to user_order" do
        expect(response).to redirect_to user_order_path
      end
    end

    context "when status not open" do
      before do
        order.cancelled!
        put :cancel, params: {user_id: order.user.id, id: order.id }
      end
      it "display flash danger" do
        expect(flash[:danger]).to eq I18n.t("orders.update_fail")
      end
      it "redirect to root_url" do
        expect(response).to redirect_to user_order_path
      end
    end
  end
  describe "POST #create" do
    let!(:product) {FactoryBot.create :product}
    before do
      log_in user
      session[:cart] = {}
    end

    context "when user click radio button address" do
      let!(:address) {FactoryBot.create :address, user_id: user.id}
      before do
        session_params = { product.id.to_s => Settings.option_1 }
        session[:cart] = session_params
        post :create, params: {
          user_id: user.id,
          address_id: address.id,
          session: session_params
        }
      end

      it "flash display success" do
        expect(flash[:success]).to eq I18n.t("orders.order_success")
      end
      it "redirect to user_orders" do
        expect(response).to redirect_to user_orders_path(user)
      end
    end

    context "when user input address" do
      before do
        session_params = {product.id.to_s => Settings.option_1}
        session[:cart] = session_params
        post :create, params: {
          user_id: user.id,
          address: "Nguyen Tan Thang_01, Da Nang_01",
          session: session_params
        }
      end

      it "flash display success" do
        expect(flash[:success]).to eq I18n.t("orders.order_success")
      end
      it "redirect to user_orders" do
        expect(response).to redirect_to user_orders_path(user)
      end
    end
  end
end
