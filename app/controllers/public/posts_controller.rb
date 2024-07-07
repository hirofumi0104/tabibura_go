class Public::PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :show, :destroy,]
  before_action :authenticate_user!, unless: :admin_signed_in?
  # ゲストユーザーが特定のアクションを実行できないように制限する
  before_action :ensure_not_guest, only: [:new, :create, :edit, :update, :destroy]

   # 新規投稿
  def new
    @post = Post.new
    @post.build_map
    @post.images.build
  end
  
  # 投稿とGoogleマップを取得
  def show
    @post = Post.includes(:map,images: { image_attachment: :blob }).find(params[:id])
  end

  def index
    @users = User.all.includes(:profile_image_attachment) 
    @posts = Post.all
    # ページネーション
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
    
    # ページネーション
    @total_posts = @posts.size
    @posts = @posts.offset((@page - 1) * @posts_per_page).limit(@posts_per_page)
    
    # ユーザー検索のため
    if params[:user_q].present?
      @users = User.where('name LIKE ?', "%#{params[:user_q]}%").includes(:profile_image_attachment)
    else
      @users = User.includes(:profile_image_attachment)
    end
  end
  
  # 下書き一覧
  def draft
    @posts = current_user.posts.includes(images: { image_attachment: :blob }).unpublished
    # カテゴリでの検索ため
    if params[:itinerary].present? && params[:itinerary] != 'all'
      @posts = @posts.where(itinerary: params[:itinerary])
    end
    
    # ページネーション
    @posts = @posts.page(params[:page]).per(10) 
    @total_posts = @posts.total_count
    @posts_per_page = 10
    @page = params[:page].to_i || 1
  end
  
  # 投稿の編集
  def edit
    @from_draft = params[:from_draft] == 'true'
  end
  
  # お気に入り登録している投稿一覧
  def nice
    @itinerary = params[:itinerary]
    @favorite_posts = current_user.favorite_posts.includes(images: { image_attachment: :blob })
    @favorite_posts = @favorite_posts.where(itinerary: @itinerary) if @itinerary.present?
    
    # ページネーションの追加
    @favorite_posts = @favorite_posts.page(params[:page]).per(10) 
    @total_posts = @favorite_posts.total_count
    @posts_per_page = 10
    @page = params[:page].to_i || 1
  end
  
   # 投稿
  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    tags = Vision.get_image_data(post_params[:main_image])
    
    if params[:save_as_draft].present? || params[:submit_post].nil?
      @post.status = 'unpublished'
    else
      @post.status = 'published'
    end

    if @post.save
      
      tags.each do |tag|
        @post.tags.create(name: tag)
      end
      if @post.unpublished?
        redirect_to draft_posts_path, notice: '投稿の下書きに保存しました。'
      else
        redirect_to posts_path, notice: '投稿しました。', replace: true
      end
    else
      render :new
    end
  end
  
  # 投稿を更新
  def update
    @post = Post.find(params[:id])
    tags = Vision.get_image_data(post_params[:main_image])
    if params[:save_as_draft].present?
      @post.status = 'unpublished'
    else
      @post.status = 'published'
    end
  
    if @post.update(post_params)
      tags.each do |tag|
        @post.tags.create(name: tag)
      end
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
        # 管理者がログインしている場合、通知を作成する
        if admin_signed_in?
          Notification.create(
            user: @post.user,
            admin: current_admin, # ログインしている管理者
            post: @post
          )
        end
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
  
  # 特定のタグが付いた投稿を表示
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
  
  # ゲストユーザーがアクセスできないよう
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
