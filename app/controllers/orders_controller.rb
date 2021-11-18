class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_order, :load_order_details, only: %i(show cancel)
  authorize_resource

  def index
    @orders = current_user.all_orders
                          .page(params[:page])
                          .per(Settings.show_5)
  end

  def new
    if session[:cart].blank?
      flash[:danger] = t "cart_empty"
      redirect_to root_path
    else
      qtity = session[:cart]
      @carts = Product.find_products_cart(qtity.keys)
      @total = total_money @carts
    end
  end

  def create
    ActiveRecord::Base.transaction do
      qtity = session[:cart]
      @carts = Product.find_products_cart(qtity.keys)
      @total = total_money @carts
      save_address
      order = save_order(@add)
      save_order_details order
      order.save!
      session.delete :cart
      flash[:success] = t "orders.order_success"
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = t "orders.order_fail"
  ensure
    redirect_to user_orders_path(current_user)
  end

  def show; end

  def cancel
    if @order.open?
      @order.cancelled!
      send_mail
    else
      flash[:danger] = t "orders.update_fail"
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = t "orders.update_fail"
  else
    flash[:success] = t "orders.order_changed"
  ensure
    redirect_back(fallback_location: user_order_path)
  end

  private

  def load_order
    @order = current_user.orders.find_by(id: params[:id])
    return if @order

    flash[:danger] = t "orders.no_order"
    redirect_to root_path
  end

  def load_order_details
    @order_details = @order.order_details.includes(:product)
    @total = total_order @order_details
  end

  def total_order order_details
    order_details.reduce(0) do |total, order|
      total + order.quantity * order.price
    end
  end

  def total_money arr
    arr.reduce(0) do |sum, item|
      sum + session[:cart][item.id.to_s] * item.price
    end
  end

  def send_mail
    UserMailer.order_status(@order, @order_details, @total).deliver_now
  end

  def save_address
    if params[:address].present?
      address_arr = params[:address].split("_")
      @add = current_user.addresses.create!(
        name: address_arr[0],
        phone: address_arr[1],
        address: address_arr[2],
        user_id: current_user.id
      )
    else
      @add = Address.find_by(id: params[:address_id])
    end
  end

  def save_order add
    current_user.orders.build(
      name: add.name,
      phone: add.phone,
      address: add.address,
      total_price: @total,
      address_id: add.id
    )
  end

  def save_order_details order
    qtity = session[:cart]
    qtity.each do |product_id, quantity|
      next if product_id.nil?

      product = Product.find_by(id: product_id)
      order.order_details.build(
        quantity: quantity,
        price: product.price,
        product_id: product_id
      )
      remaining_quantity = product.quantity - quantity
      product.update!(quantity: remaining_quantity)
    end
  end
end
