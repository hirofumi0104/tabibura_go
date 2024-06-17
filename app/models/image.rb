class Image < ApplicationRecord
   belongs_to :post
   has_one_attached :image
   validates :image, presence: { message: "写真をアップロードしてください。" }
   validates :description, presence: { message: "説明を入力してください。" }
end
