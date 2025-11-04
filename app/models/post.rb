class Post < ApplicationRecord
   
  # 公開と非公開のステータスの定義
  enum :status, { unpublished: 0, published: 1 }

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
  attribute :reported, :boolean
  
  validates :itinerary, presence: { message: "旅先を選択してください。" }
  validates :caption, presence: { message: "旅先説明を入力してください。" }
  validates :main_image, presence: { message: "見出し写真をアップロードしてください。" }
  validate :at_least_one_image
  
  
  
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
  
  # 投稿一覧画面の検索条件 Postコントローラー(index)
  scope :search, ->(q) { where("unaccent(caption) ILIKE unaccent(?) OR unaccent(itinerary) ILIKE unaccent(?)",
          "%#{q}%", "%#{q}%")}
  scope :with_tag, ->(tag) { joins(:tags).where(tags: {name: tag.delete('#')}) if tag.present? }
  scope :by_itinerary, ->(ininerart) { where(ininerart:) if ininerart.present? }

  private

    def at_least_one_image
      if images.empty?
        errors.add(:images, "旅先レポート写真を追加してください。")
      end
    end
    
end
