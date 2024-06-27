class Post < ApplicationRecord
   belongs_to :user
   has_one_attached :main_image
   has_one :map, dependent: :destroy
   has_many :comments, dependent: :destroy
   has_many :reports, as: :reportable, dependent: :destroy
   has_many :favorites, dependent: :destroy
   has_many :images, dependent: :destroy
   has_many :taggings, dependent: :destroy
   has_many :tags, through: :taggings, dependent: :destroy
   # （画像と地図）
   accepts_nested_attributes_for :images, allow_destroy: true
   accepts_nested_attributes_for :map, allow_destroy: true
   after_update :send_notification_if_unpublished, if: -> { saved_change_to_status? && status == 'unpublished' }
   attribute :reported, :boolean
   
   validates :itinerary, presence: { message: "旅先を選択してください。" }
   validates :caption, presence: { message: "旅先説明を入力してください。" }
   validates :main_image, presence: { message: "見出し写真をアップロードしてください。" }
   validate :at_least_one_image
   
   # 公開と非公開のステータスの定義
  # enum status: { unpublished: 0, published: 1 }
    # 公開の投稿を取得するため
  # scope :published, -> { where(status: :published) }
  # # 未公開の投稿を取得するため
  # scope :unpublished, -> { where(status: :unpublished) }
   
    # タグリストを取得する
   def tag_list
    tags.map { |tag| "##{tag.name}" }.join(', ')
   end
   # タグリストを設定する
   def tag_list=(names)
    self.tags = names.split(',').map do |name|
      Tag.where(name: name.strip.delete('#')).first_or_create!
    end
   end
   # ユーザーがお気に入り登録しているかを確認する
   def favorited_by?(user)
      favorites.where(user_id: user.id)
   end
   
   private

   def at_least_one_image
    if images.empty?
      errors.add(:images, "少なくとも一つの旅先レポート写真を追加してください。")
    end
   end
   # ステータスが「未公開」に変更された場合に通知を送信する
   def send_notification_if_unpublished
    if saved_change_to_status? && status_was == 'published' && status == 'unpublished'
      Notification.create(
        user: user,
        post: self,
        read: false
      )
    end
   end
end
