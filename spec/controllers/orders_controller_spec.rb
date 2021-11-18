require "rails_helper"
include SessionsHelper

RSpec.describe OrdersController, type: :controller do
  let(:user) {FactoryBot.create :user}

  describe "GET #index" do
    context "when user unlogged" do
      subject {get :index, params: {locale: I18n.locale, user_id: user.id}}

      it "redirect to the login" do
        expect(subject).to redirect_to new_user_session_path
      end
      it "not redirect different url" do
        expect(subject).to_not redirect_to root_url
      end
    end

    context "when user is logged" do
      let!(:order) {FactoryBot.create :order}
      before do
        sign_in order.user
        @order = order.user.all_orders
        get :index, params: {user_id: order.user.id}
      end

      it "assigns @orders" do
        expect(assigns(:orders)).to eq @order
      end
      it "redirect to the root_url" do
        expect(response).to render_template :index
      end
    end
  end

  describe "GET #show" do
    let!(:order) {FactoryBot.create :order, user_id: user.id}
    before do
      sign_in order.user
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
      it "renders the show template" do
        expect(response).to render_template :show
      end
    end

    context "when order not exist" do
      before do
        get :show, params: {
          user_id: order.user.id,
          id: Settings.rspec.length_negative_1
        }
      end

      it "redirect to the root_url" do
        expect(response).to redirect_to root_url
      end
      it "display flash" do
        expect(flash[:danger]).to eq I18n.t("orders.no_order")
      end
    end
  end

  describe "GET #new" do
    before do
      sign_in user
      session[:cart] = {}
      get :new, params: {user_id: user.id}
    end

    context "when cart empty" do
      it "redirect to the root_url" do
        expect(response).to redirect_to root_path
      end
      it "display flash" do
        expect(flash[:danger]).to eq I18n.t("cart_empty")
      end
    end

    context "when cart has item" do
      let!(:product) {FactoryBot.create :product}
      before do
        session_params = {product.id.to_s => Settings.rspec.quantity_1}
        session[:cart] = session_params
        get :new, params: {user_id: user.id, session: session_params}
      end

      it "assigns @carts" do
        @carts = Product.find_products_cart(session[:cart].keys)
        expect(assigns(:carts)).to eq @carts
      end
      it "renders the new template" do
        expect(response).to render_template :new
      end
    end
  end

  describe "PUT #cancel" do
    let!(:order) {FactoryBot.create :order, status: :open, user_id: user.id}
    before do
      sign_in order.user
    end

    context "when order status open" do
      before do
        put :cancel, params: {user_id: order.user.id, id: order.id }
      end
      it "flash success" do
        expect(flash[:success]).to eq I18n.t("orders.order_changed")
      end
      it "redirect to the user_order" do
        expect(response).to redirect_to user_order_path
      end
    end

    context "when status not open" do
      before do
        order.cancelled!
        put :cancel, params: {user_id: order.user.id, id: order.id }
      end
      it "show flash danger" do
        expect(flash[:danger]).to eq I18n.t("not_permission")
      end
      it "redirect to the root_url" do
        expect(response).to redirect_to root_path
      end
    end
  end
  describe "POST #create" do
    let!(:product) {FactoryBot.create :product}
    before do
      sign_in user
      session[:cart] = {}
    end

    context "when choosen radio button address" do
      let!(:address) {FactoryBot.create :address, user_id: user.id}
      before do
        session_params = {product.id.to_s => Settings.rspec.quantity_1}
        session[:cart] = session_params
        post :create, params: {
          user_id: user.id,
          address_id: address.id,
          session: session_params
        }
      end

      it "flash success" do
        expect(flash[:success]).to eq I18n.t("orders.order_success")
      end
      it "redirect to the user_orders" do
        expect(response).to redirect_to user_orders_path(user)
      end
    end

    context "when input address" do
      before do
        session_params = {product.id.to_s => Settings.rspec.quantity_1}
        session[:cart] = session_params
        post :create, params: {
          user_id: user.id,
          address: "Nguyen Van A_NHS, Da Nang _09099999",
          session: session_params
        }
      end

      it "flash success" do
        expect(flash[:success]).to eq I18n.t("orders.order_success")
      end
      it "redirect to the user_orders" do
        expect(response).to redirect_to user_orders_path(user)
      end
    end
  end
end
