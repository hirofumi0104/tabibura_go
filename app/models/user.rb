class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:name]
         
  has_many :posts, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_posts, through: :favorites, source: :post
  has_many :notifications, dependent: :destroy
  has_many :reports, dependent: :destroy 
  has_one_attached :profile_image
  # 退会確認用
  attr_accessor :withdrawal_confirmation
  
  # フォロー機能
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
     email == 'admin@example.com' 
  end
  
   # ゲストユーザーかどうかを判定する
  def guest?
    email == 'guest@example.com'
  end
  
   # ゲストユーザーを作成
  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
      user.password = SecureRandom.urlsafe_base64
      user.name = "Guest User"
    end
  end
  
end
