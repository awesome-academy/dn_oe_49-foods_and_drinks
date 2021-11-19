class Admin::OrdersController < Admin::AdminsController
  load_and_authorize_resource
  before_action :load_order, :load_order_details,
                except: %i(index index_by_status)
  before_action :check_quantity_product, only: :approve

  def index
    @title = t "orders.all"
    @orders = Order.includes(:order_details, :user)
                   .recent_orders.page(params[:page])
                   .per(Settings.show_10)
  end

  def index_by_status
    @title = t "status_order.#{params[:status]}"
    load_orders params[:status]
  end

  def show
    @title = t "orders.order_detail"
  end

  # change status open to confirmed
  def approve
    ActiveRecord::Base.transaction do
      if @order.open?
        update_quantity_product
        @order.confirmed!
        send_mail
        flash[:success] = t "orders.approve_success"
      else
        flash[:danger] = t "orders.approve_failed"
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = t "orders.approve_failed"
  ensure
    redirect_back(fallback_location: root_path)
  end

  # chang status open to disclaim
  def reject
    ActiveRecord::Base.transaction do
      add_quantity_product if @order.confirmed?
      @order.disclaim!
      send_mail
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = t "orders.reject_failed"
  else
    flash[:success] = t "orders.reject_success"
  ensure
    redirect_back(fallback_location: admin_orders_path)
  end

  # change status confirmed to completed
  def update
    if @order.confirmed?
      @order.completed!
      send_mail
    else
      flash[:danger] = t "orders.update_fail"
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = t "orders.update_fail"
  else
    flash[:success] = t "orders.order_changed"
  ensure
    redirect_back(fallback_location: admin_orders_path)
  end

  private

  # only load 1 order param id
  def load_order
    @order = Order.find_by(id: params[:id])
    return if @order

    flash[:danger] = t "orders.no_order"
    redirect_to admin_orders_path
  end

  # load order details, total price
  def load_order_details
    @order_details = @order.order_details.includes(:product)
    @total = total_order @order_details
  end

  def load_orders status
    if check_status? status
      @orders = Order.send(status)
                     .includes(:order_details, :user)
                     .recent_orders.page(params[:page])
                     .per(Settings.show_10)
      render :index
    else
      flash[:success] = t "error_path"
      redirect_to admin_orders_path
    end
  end

  def total_order order_details
    order_details.reduce(0) do |total, order|
      total + order.quantity * order.price
    end
  end

  # check param status exists in the enum model order
  def check_status? status
    Order.statuses.include?(status)
  end

  def send_mail
    UserMailer.order_status(@order, @order_details, @total).deliver_now
  end

  # update quantity products when approved order
  def update_quantity_product
    @order_details.each do |detail|
      product = detail.product
      product.quantity -= detail.quantity
      product.save!
    end
  end

  # update quantity product when reject
  def add_quantity_product
    @order_details.each do |detail|
      product = detail.product
      product.quantity += detail.quantity
      product.save!
    end
  end

  # check quantity product with quantity in order detail
  def check_quantity_product
    prd_name = ""
    @order_details.each do |detail|
      if detail.product.quantity < detail.quantity
        prd_name << detail.product_name << ", "
      end
    end
    return if prd_name.blank?

    flash[:danger] = t("orders.quantity_not_enough") << prd_name
    redirect_back(fallback_location: admin_orders_path)
  end
end
