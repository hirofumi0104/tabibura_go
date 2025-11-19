class Post < ApplicationRecord
   
  # 公開と非公開のステータスの定義
  enum :status, { unpublished: 0, published: 1 }

  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :favorites, dependent: :destroy
  
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings, dependent: :destroy
   
  # 投稿内容の関連付け
  has_one_attached :main_image
  has_many :images, dependent: :destroy
  has_many :map_pins, dependent: :destroy
  # 投稿・編集画面のバリデーション
  validates :itinerary, presence: { message: "旅先を選択してください。" }
  validates :caption, presence: { message: "テーマを入力してください。" }
  validates :main_image, presence: { message: "見出し写真をアップロードしてください。" }
  
  # （画像と地図）
  accepts_nested_attributes_for :images, allow_destroy: true
  accepts_nested_attributes_for :map_pins, allow_destroy: true


  
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
    
end
