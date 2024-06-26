class Public::UsersController < ApplicationController
   before_action :set_user, only: [:show, :edit, :update, :unsubscribe]
   before_action :authenticate_user!
   before_action :ensure_not_guest, only: [:edit, :update, :destroy]

   
  def show
    @notifications = current_user.notifications.order(created_at: :desc)
    
    if params[:itinerary].present?
      @posts = @user.posts.published.where(itinerary: params[:itinerary]).includes(images: { image_attachment: :blob })
    else
      @posts = @user.posts.published.includes(images: { image_attachment: :blob })
    end
    
    @posts = @posts.page(params[:page]).per(10) # ページネーションの追加
    @total_posts = @posts.total_count
    @posts_per_page = 10
    @page = params[:page].to_i || 1
  end

  def edit
  end
  
  def update
    if @user.update(user_params)
      redirect_to show_mypage_user_path, notice: 'プロフィールが更新されました。'
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
  
  def ensure_not_guest
    if current_user.guest?
      redirect_to root_path, alert: 'ゲストユーザーはこの機能を使用できません。会員登録をしてください。'
    end
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :biography, :profile_image, :withdrawal_confirmation)
  end
end