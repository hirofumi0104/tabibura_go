class Public::HomesController < ApplicationController
  def top
    @posts =Post.order('id DESC').limit(4)
    @recommended_posts = Post.order("RANDOM()").limit(4)
  end

  def about
  end
end
