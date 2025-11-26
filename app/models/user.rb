class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_posts, through: :favorites, source: :post
  has_many :notifications, dependent: :destroy
  has_many :reports, dependent: :destroy 
  has_one_attached :profile_image
  
  # 退会確認用
  attr_accessor :withdrawal_confirmation
  
  # フォローしている関連付け
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # フォローされている関連付け
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  # フォローしているユーザーを取得
  has_many :followings, through: :active_relationships, source: :followed
  # フォロワーを取得
  has_many :followers, through: :passive_relationships, source: :follower
  
  # 指定したユーザーをフォローする
  def follow(user)
    active_relationships.create(followed_id: user.id)
  end
  
  # 指定したユーザーのフォローを解除する
  def unfollow(user)
    active_relationships.find_by(followed_id: user.id).destroy
  end
  
  # 指定したユーザーをフォローしているかどうかを判定
  def following?(user)
    followings.include?(user)
  end

  # ユーザーがアクティブかどうかを判定する
  def active_for_authentication?
    super && is_active
  end
  
  # ユーザーが非アクティブな場合
  def inactive_message
    is_active ? super : :inactive
  end
  
   # 管理者ユーザーかどうかを判定
  def admin?
    role == 1
  end
  
  # ページネーションで使用
  scope :is_active, -> { where(is_active: true) }

  # 投稿画面のユーザー検索条件 Postコントローラー(index)
  scope :excluding_admin, -> { where.not(role: 1) }
  scope :search_name, ->(q) { where('name LIKE ?', "%#{q}%") if q.present? }

  # 管理者と一般ユーザーのログイン方法を変えるための設定
  attr_accessor :login

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login) # フォームで送る login フィールドを取得
    
    if login
      if login.include?('@') # メール形式なら管理者ログイン想定
        where(email: login).first
      else
        where(name: login).first # 一般ユーザーは名前でログイン
      end
    else
      super
    end
  end

end
