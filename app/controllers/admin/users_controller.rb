class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!
  
  def show
    @user = User.find(params[:id])
    @posts = @user.posts
    
    if params[:itinerary].present?
      @posts = @posts.where(itinerary: params[:itinerary])
    end
     @posts = @posts.page(params[:page]).per(9)
  end
  
  def index
    @users = User.all
    @users = @users.page(params[:page]).per(10)
    # 名前でユーザーを検索する
    if params[:search].present?
      @users = @users.where("name LIKE ?", "%#{params[:search]}%") if params[:search].present?
    end
    # アクティブ状態のユーザーを表示
    if params[:status].present?
      @users = @users.where(is_active: params[:status] == 'active')
    end
  end
  
  # ユーザーのステータスをアクティブに
  def activate
    @user = User.find(params[:id])
    @user.update(is_active: true)
    redirect_back(fallback_location: admin_users_path, notice: 'ユーザーをログイン可能にしました。')
  end

  # ユーザーを非アクティブ化に
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
