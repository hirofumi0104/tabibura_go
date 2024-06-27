class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!
  def top
    # 通報された投稿
    @reported_posts = Post.joins(:reports).distinct
    @reported_posts_count = @reported_posts.count
    @reported_posts_per_page = 5
    @reported_posts = @reported_posts.offset(offset).limit(@reported_posts_per_page)
    # 通報されたコメント
    @reported_comments = Comment.joins(:reports).distinct
    @reported_comments_count = @reported_comments.count
    @reported_comments_per_page = 5
    @reported_comments = @reported_comments.offset(offset).limit(@reported_comments_per_page)
  end
end

private

# ページネーション
def offset
  (params[:page].to_i - 1) * @reported_posts_per_page
end
