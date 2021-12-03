class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_locale, :initializ_session
  add_flash_types :info, :error, :warning
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: User::ADDED_ATTRS
    devise_parameter_sanitizer.permit :account_update, keys: User::ADDED_ATTRS
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
