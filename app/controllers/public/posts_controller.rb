class Public::PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :show, :destroy]
  before_action :authenticate_user!, unless: :admin_signed_in?
  before_action :ensure_not_guest, only: [:new, :create, :edit, :update, :destroy]

  
  def new
    @post = Post.new
    @post.build_map
    @post.images.build
  end
  
  def show
    @post = Post.includes(:map,images: { image_attachment: :blob }).find(params[:id])
  end

  def index
    @users = User.all.includes(:profile_image_attachment) 
    @page = (params[:page] || 1).to_i
    @posts_per_page = 10

    if params[:q].present?
      @posts = Post.published.where('caption LIKE ? OR itinerary LIKE ?', "%#{params[:q]}%", "%#{params[:q]}%").includes(images: { image_attachment: :blob })
    elsif params[:tag].present?
      @posts = Post.published.joins(:tags).where(tags: { name: params[:tag].delete('#') }).includes(images: { image_attachment: :blob })
    # 公開中の投稿一覧を表示する
    elsif params[:itinerary].present?
      @posts = Post.published.where(itinerary: params[:itinerary]).includes(images: { image_attachment: :blob })
    else
      @posts = Post.published.includes(images: { image_attachment: :blob })
    end
    
    @total_posts = @posts.size
    @posts = @posts.offset((@page - 1) * @posts_per_page).limit(@posts_per_page)
    
    # ユーザー検索のため
    if params[:user_q].present?
      @users = User.where('name LIKE ?', "%#{params[:user_q]}%").includes(:profile_image_attachment)
    else
      @users = User.includes(:profile_image_attachment)
    end
  end
  
  def draft
    @posts = current_user.posts.includes(images: { image_attachment: :blob }).unpublished
    # カテゴリでの検索ため
    if params[:itinerary].present? && params[:itinerary] != 'all'
      @posts = @posts.where(itinerary: params[:itinerary])
    end
    
    @posts = @posts.page(params[:page]).per(10) # ページネーションの追加
    @total_posts = @posts.total_count
    @posts_per_page = 10
    @page = params[:page].to_i || 1
  end

  def edit
    @from_draft = params[:from_draft] == 'true'
  end
  
  def nice
    @itinerary = params[:itinerary]
    @favorite_posts = current_user.favorite_posts.includes(images: { image_attachment: :blob })
    @favorite_posts = @favorite_posts.where(itinerary: @itinerary) if @itinerary.present?
    
    @favorite_posts = @favorite_posts.page(params[:page]).per(10) # ページネーションの追加
    @total_posts = @favorite_posts.total_count
    @posts_per_page = 10
    @page = params[:page].to_i || 1
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    
    if params[:save_as_draft].present? || params[:submit_post].nil?
      @post.status = 'unpublished'
    else
      @post.status = 'published'
    end
    
    if @post.save
      if @post.unpublished?
        redirect_to draft_posts_path, notice: '投稿の下書きに保存しました。'
      else
        redirect_to posts_path, notice: '投稿しました。', replace: true
      end
    else
      render :new
    end
  end
  
  def update
    @post = Post.find(params[:id])
  
    if params[:save_as_draft].present?
      @post.status = 'unpublished'
    else
      @post.status = 'published'
    end
  
    if @post.update(post_params)
      if @post.unpublished?
        redirect_to draft_posts_path, notice: '投稿を下書きとして保存しました。'
      else
        redirect_to post_path(@post, referrer: user_path(@post.user)), notice: '投稿を更新しました。'
      end
    else
      render :edit
    end
  end

 # 投稿のステータス
  def update_status
    @post = Post.find(params[:id])
    if @post.update(post_params)
      if @post.published?
        flash[:notice] = '投稿を公開しました。'
      else
        flash[:notice] = '投稿を非公開にしました。'
       
      end
      if admin_signed_in?  # 管理者がログインしているかどうかを確認する条件
        redirect_to request.referer
      else
        redirect_to draft_posts_path
      end
    else
      render :draft
    end
  end
  
  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_back(fallback_location: root_path, notice: '投稿を削除しました')
  end
  
  def tagged
    @tag = params[:tag].delete('#')
    @posts = Post.joins(:tags).where(tags: { name: @tag.delete('#') })
    @users = User.all 
    render :index
  end
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
  
  def ensure_not_guest
    if current_user.guest?
      redirect_to root_path, alert: 'ゲストユーザーはこの機能を使用できません。会員登録をしてください。'
    end
  end
  
  def post_params
    params.require(:post).permit(:user_id, :itinerary, :caption,:status, :main_image, :tag_list, :latitude, :longitude,
     map_attributes: [:id, :latitude, :longitude],
     images_attributes: [:id, :description, :image, :_destroy])
  end
  
end
