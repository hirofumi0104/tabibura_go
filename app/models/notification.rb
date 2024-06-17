class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :comment
  
  after_initialize :set_default_values

  private

  def set_default_values
    self.read ||= false
  end
end
