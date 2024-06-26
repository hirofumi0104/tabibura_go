class Public::NotificationsController < ApplicationController
   before_action :authenticate_user!
   
  # 通知を既読にして削除するアクション
  def mark_as_read_and_destroy
    @notification = Notification.find(params[:id])
    @notification.update(read: true) # 通知を既読
    @notification.destroy
    redirect_to @notification.post
  end
  
  # 投稿が非公開に設定された際にユーザーに通知を送るアクション
  def send_unpublish_notification
    @post = Post.find(params[:post_id])# 非公開に設定された投稿を取得
    @user = @post.user
    
    # Notification モデルに新しい通知を作成する
    Notification.create(
      user: @user,
      post: @post,
      read: false
    )

  end
end
