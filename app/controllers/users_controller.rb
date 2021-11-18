class UsersController < ApplicationController
  before_action :authenticate_user!, :load_user, only: :show
  authorize_resource

  def show; end

  private

  def load_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:danger] = t "user_not_found"
    redirect_to root_url
  end
end
