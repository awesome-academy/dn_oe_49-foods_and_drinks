class ProductsController < ApplicationController
  before_action :load_product, only: :show
  before_action :categories_select_id_name, only: %i(index filter)
  authorize_resource

  def index
    @products = Product.enabled
                       .find_name(params[:name])

    if @products.empty?
      @products = Product
      flash.now[:danger] = t "menu_page.search_pro_nil"
    end

    @products = @products.recent_products
                         .page(params[:page])
                         .per(Settings.per_page_16)
    render "static_pages/menu"
  end

  def new; end

  def create; end

  def show; end

  def filter
    @products = Product.enabled
                       .filter_category(params[:category_id])
                       .page(params[:page])
                       .per(Settings.per_page_16)
    flash.now[:danger] = t "menu_page.filter_category_nil" if @products.empty?
    render "static_pages/menu"
  end

  private

  def load_product
    @product = Product.find_by(id: params[:id])
    return if @product

    flash[:danger] = t "show_product_fail"
    redirect_to root_url
  end
end
