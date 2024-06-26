class Public::FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_post
  
  # お気に入り登録する
  def create
    @post.favorites.create(user: current_user)
    redirect_back(fallback_location: root_path)
  end
  
  # お気に入り解除する
  def destroy
    favorite = @post.favorites.find_by(user: current_user)
    favorite.destroy if favorite
    redirect_back(fallback_location: root_path)
  end

  private

  def find_post
    @post = Post.find(params[:post_id])
  end
end
