class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!
  
  def show
    @user = User.find(params[:id])
    @posts = @user.posts
  end
  
  def index
    @users = User.all
    if params[:search].present?
      @users = @users.where("name LIKE ?", "%#{params[:search]}%") if params[:search].present?
    end
    if params[:status].present?
      @users = @users.where(is_active: params[:status] == 'active')
    end
  end
  
  def activate
    @user = User.find(params[:id])
    @user.update(is_active: true)
    redirect_back(fallback_location: admin_users_path, notice: 'ユーザーをログイン可能にしました。')
  end

  def deactivate
    @user = User.find(params[:id])
    @user.update(is_active: false)
    redirect_back(fallback_location: admin_users_path, notice: 'ユーザーをログイン不可にしました。')
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
