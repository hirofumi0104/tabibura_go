class Public::NotificationsController < ApplicationController
   before_action :authenticate_user!
   
  # 通知を既読にして削除するアクション
  def mark_as_read_and_destroy
    @notification = Notification.find(params[:id])
    @notification.update(read: true) # 通知を既読
    @notification.destroy
    redirect_to @notification.post
  end
  
end
