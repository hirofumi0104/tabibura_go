class Public::FavoritesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_post
  
  # お気に入り登録する
  def create
    @post.favorites.create(user: current_user)

    render json: {
      target_class: "favorite-btn-#{@post.id}",
      html: render_to_string(
        partial: "layouts/nice",
        locals: { post: @post }
      )
    }
  end

  def destroy
    @post.favorites.find_by(user: current_user)&.destroy

    render json: {
      target_class: "favorite-btn-#{@post.id}",
      html: render_to_string(
        partial: "layouts/nice",
        locals: { post: @post }
      )
    }
  end

  private

  def find_post
    @post = Post.find(params[:post_id])
  end
end
