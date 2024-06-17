class Public::RelationshipsController < ApplicationController
  before_action :authenticate_user!
  # ユーザーをフォローするアクション
  def create
    user = User.find(params[:user_id])
    current_user.follow(user)
    redirect_to request.referer
  end
  # ユーザーのフォローを解除するアクション
  def destroy
    user = User.find(params[:user_id])
    current_user.unfollow(user)
    redirect_to request.referer
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