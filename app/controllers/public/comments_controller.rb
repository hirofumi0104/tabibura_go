class Public::CommentsController < ApplicationController
  before_action :set_post
  
  # コメントを作成する
  def create
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to post_path(@post), notice: "コメントしました"
    end
  end
  
  # コメントを削除する
  def destroy
    @comment = Comment.find(params[:id])
    @post = @comment.post
    @comment.destroy
    redirect_to post_path(@post), notice: 'コメントを削除しました。'
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end