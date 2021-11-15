class ApplicationController < ActionController::Base
  include SessionsHelper
  before_action :set_locale
  add_flash_types :info, :error, :warning
  before_action :initializ_session
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from CanCan::AccessDenied, with: :access_denied
  rescue_from ActiveRecord::RecordNotFound,
              with: :active_record_record_not_found
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

  def current_ability
    controller_name_segments = params[:controller].split("/")
    controller_name_segments.pop
    controller_namespace = controller_name_segments.join("/").camelize
    @current_ability ||= Ability.new(current_user, controller_namespace)
  end

  def access_denied
    flash[:danger] = t "not_permission"
    redirect_to root_url
  end

  def active_record_record_not_found
    flash[:danger] = t "devise.not_record"
    redirect_to root_url
  end
end
