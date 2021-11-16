class Admin::ProductsController < Admin::AdminsController
  before_action :load_product,
                only: %i(show edit update purge_thumbnail destroy)
  before_action :load_order_details_with_product_id, only: :destroy

  def index
    @products = Product.recent_products
                       .page(params[:page])
                       .per(Settings.per_page_15)
  end

  def import
    arr_message = import_data params[:file]
    if arr_message.empty?
      flash[:success] = t "product_controller.msg_import_success"
    else
      flash[:info] = arr_message
    end
    redirect_to admin_products_url
  end

  def show; end

  def new
    @product = Product.new
    @product.build_category
  end

  def purge_thumbnail
    @product.thumbnail.purge
    redirect_back fallback_location: admin_product_path(@product)
  end

  def purge_images
    imge = ActiveStorage::Attachment.find_by id: params[:id]
    imge.purge
    redirect_back fallback_location: admin_root_path
  end

  def edit; end

  def update
    if @product.update(product_params)
      flash[:success] = t "update_product.msg_update_success"
      redirect_to admin_product_path(@product)
    else
      flash[:danger] = t "update_product.msg_update_fail"
      render :edit
    end
  end

  def create
    @product = Product.new product_params
    if @product.save
      flash[:info] = t "product_controller.msg_create_success"
      redirect_to admin_product_path(@product)
    else
      flash[:danger] = t "product_controller.msg_create_fail"
      render :new
    end
  end

  def destroy
    if @order_details.present?
      check_status
    else
      @product.destroy
      flash[:success] = t "product_controller.msg_delete_success"
    end
    redirect_to admin_products_path
  end

  private

  def product_params
    params.require(:product)
          .permit(:thumbnail, :name, :price, :description, :quantity,
                  :status, :category_id, images: [],
                  category_attributes: [:name, :description])
  end

  def load_product
    @product = Product.find_by id: params[:id]
    return if @product

    flash[:danger] = t "product_controller.msg_show_failer"
    redirect_to admin_products_path
  end

  def load_order_details_with_product_id
    @order_details = OrderDetail.where(product_id: @product)
  end

  def check_status
    if @product.enabled?
      @product.disabled!
      flash[:success] = t "product_controller.msg_delete_change"
    else
      flash[:danger] = t "product_controller.msg_no_delete"
    end
  end

  def import_data file
    arr = []
    spreadsheet = Roo::Spreadsheet.open file
  rescue StandardError
    arr.push(I18n.t("validate_excel.format"))
    arr
  else
    header = spreadsheet.row(Settings.row_1)
    if (header - Product.column_names).any?
      arr.push(I18n.t("validate_excel.model_fail"))
      return arr
    else
      Product.handle_check spreadsheet, header, arr
    end
  end
end
