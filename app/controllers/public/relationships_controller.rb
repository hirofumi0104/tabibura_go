class Public::RelationshipsController < ApplicationController
  before_action :authenticate_user!
  # ユーザーをフォローするアクション
  def create
    @user = User.find(params[:user_id])
    current_user.follow(@user)

    render json: {
      target_class: "follow-btn-#{@user.id}",
      html: render_to_string(
        partial: "layouts/followbtn",
        locals: { user: @user }
      )
    }
  end

  def destroy
    @user = User.find(params[:user_id])
    current_user.unfollow(@user)

    render json: {
      target_class: "follow-btn-#{@user.id}",
      html: render_to_string(
        partial: "layouts/followbtn",
        locals: { user: @user }
      )
    }
  end
  # ユーザーがフォローしているユーザー一覧を表示するアクション
  def followings
    @user = User.find(params[:user_id])
    @users = @user.followings
    render 'public/relationships/show_follow'
  end
  # ユーザーをフォローしているユーザー一覧を表示するアクション
  def followers
    @user = User.find(params[:user_id])
    @users = @user.followers
    render 'public/relationships/show_follow'
  end
end