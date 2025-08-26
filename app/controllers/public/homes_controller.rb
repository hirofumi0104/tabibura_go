class Public::HomesController < ApplicationController
  def top
    # 最新の投稿を4件取得、@postsに
    @posts =Post.published.order('id DESC').limit(4)
    # ランダムな投稿を4件取得、@recommended_postsに
    @recommended_posts = Post.published.order("RANDOM()").limit(4)
  end

  def about
  end
end
