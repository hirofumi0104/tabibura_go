class Public::NotificationsController < ApplicationController
   before_action :authenticate_user!

  def mark_as_read_and_destroy
    @notification = Notification.find(params[:id])
    @notification.update(read: true)
    @notification.destroy
    redirect_to @notification.post
  end
end
