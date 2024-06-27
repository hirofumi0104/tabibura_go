class Public::HomesController < ApplicationController
  def top
    # 最新の投稿を4件取得、@postsに
    @posts =Post.published.order('id DESC').limit(4)
    # ランダムな投稿を4件取得、@recommended_postsに
    if Rails.env.production?  # 本番環境の場合
      @recommended_posts = Post.published.order("RAND()").limit(4)
    else
      @recommended_posts = Post.published.order("RANDOM()").limit(4)
    end
  end

  def about
  end
end
