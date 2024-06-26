class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :notifications, dependent: :destroy
  after_create :create_notification
  
  private

  def create_notification
    Notification.create(
      user: self.post.user,
      post: self.post,
      comment: self,
      read: false
    )
  end
end
