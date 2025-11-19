class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :post, optional: true
  belongs_to :comment, optional: true
  after_initialize :set_default_read

  private

  def set_default_read
    self.read ||= false
  end
end
