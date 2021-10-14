class Admin::ProductsController < Admin::AdminsController
  def index
    @products = Product.recent_products.page(params[:page]).per(Settings.per_page)
  end
end