class Public::HomesController < ApplicationController
  def top
    # ゲストユーザー認識のためのフラグを設定
    session[:guest_user_flg] = true

    # 最新の投稿を4件取得
    @posts = Post.published.order('id DESC').limit(4)
    # ランダムな投稿を4件取得
    @recommended_posts = Post.published.order("RANDOM()").limit(4)
  end

  def about
  end
end
