class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!
  def top
    @reported_posts = Post.joins(:reports).distinct
    @reported_comments = Comment.joins(:reports).distinct
  end
end
