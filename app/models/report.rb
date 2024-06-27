class Report < ApplicationRecord
  # belongs_to :reportable, polymorphic: true
  # belongs_to :user
  validates :reason, presence: true
end
