class ApplicationController < ActionController::Base
  include SessionsHelper
  before_action :set_locale
  add_flash_types :info, :error, :warning
  before_action :initializ_session
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    signup_attrs = [:name, :email, :password, :password_confirmation]
    devise_parameter_sanitizer.permit(:sign_up, keys: signup_attrs)
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def initializ_session
    session[:cart] ||= {}
  end

  def categories_select_id_name
    @categories = Category.select(:id, :name)
  end
end
