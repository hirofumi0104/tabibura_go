class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :posts, through: :taggings, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
