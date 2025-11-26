class Public::UsersController < ApplicationController
   before_action :set_user, only: [:show, :edit, :update, :unsubscribe]
   before_action :authenticate_user!

  # ユーザーのプロフィール 
  def show
    
    @notifications = current_user.notifications.order(created_at: :desc)
    @user = User.find(params[:id])

    posts_scope = @user.posts

    case params[:status]
    when "published"
      posts_scope = posts_scope.where(status: "published")
    when "unpublished"
      posts_scope = posts_scope.where(status: "unpublished")
    end

    if params[:itinerary].present?
      posts_scope = posts_scope.where(itinerary: params[:itinerary])
    end
    @posts = posts_scope
  end

  def edit
  end
  
  def update
    if @user.update(user_params)
      redirect_to show_mypage_public_user_path, notice: 'プロフィールが更新されました。'
    else
      render :edit
    end
  end
  
  # 退会機能
  def unsubscribe
    @user.destroy
    reset_session
    redirect_to root_path, notice: '退会が完了しました。ご利用ありがとうございました。'
  end
  
 private

  def set_user
    @user = User.find(params[:id])
  end
  
  
  def user_params
    params.require(:user).permit(:name, :email, :biography, :profile_image, :withdrawal_confirmation)
  end
end