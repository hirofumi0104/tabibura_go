class Public::PostsController < ApplicationController
  # ページ作成のモジュール
  include Pagination

  before_action :set_post, only: [:edit, :update, :show, :destroy,]
  before_action :authenticate_user!, except: [:index, :show, :tagged]

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
    @users = User.where.not(role: 1).includes(:profile_image_attachment) 
    @posts = Post.all

    # 投稿の検索条件(条件はPostモデル)
    @posts = Post.published
               .search(params[:q])
               .with_tag(params[:tag])
               .by_itinerary(params[:itinerary])
               .includes(images: { image_attachment: :blob })
               .page(params[:page]).per(10)

    # ユーザー検索(条件はUserモデル)
    @users = User.excluding_admin
              .search_name(params[:user_q])
              .includes(:profile_image_attachment)
              
    # 投稿ページネーション
    post_page = params[:post_page]&.to_i || 1
    @post_pagination = paginate(@posts.published.all, page: post_page, per_page: 10)
    @posts = @post_pagination[:collection]
  
    # ユーザーサイドバーページネーション
    user_page = params[:user_page]&.to_i || 1
    @user_pagination = paginate(@users.is_active.all, page: user_page, per_page: 8)
    @users = @user_pagination[:collection]
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
    
    if params[:tagging_option] == 'cloud_vision' && post_params[:main_image].present?
      tags = Vision.get_image_data(post_params[:main_image])
    elsif params[:tagging_option] == 'manual' && params[:post][:tag_list].present?
      tags = params[:post][:tag_list].split(",").map(&:strip)
    else
      tags = []
    end
    
    if params[:save_as_draft].present? || params[:submit_post].nil?
      @post.status = 'unpublished'
    else
      @post.status = 'published'
    end

    if @post.save
       tag_objects = tags.map { |tag| { name: tag } }
       @post.tags.create(tag_objects)
      if @post.unpublished?
        redirect_to draft_posts_path, notice: '投稿の下書きに保存しました。'
      else
        redirect_to public_posts_path, notice: '投稿しました。', replace: true
      end
    else
      render :new
    end
  end
  
  # 投稿を更新
  def update
    @post = Post.find(params[:id])
    
    if params[:tagging_option] == 'cloud_vision' && post_params[:main_image].present?
      begin
        # Cloud Vision APIを使用してタグを取得
        tags = Vision.get_image_data(post_params[:main_image])
        Rails.logger.info "Cloud Vision tags: #{tags.inspect}"
      rescue => e
        Rails.logger.error "Cloud Vision API error: #{e.message}"
        tags = []
      end
    elsif params[:tagging_option] == 'manual' && params[:post][:tag_list].present?
      tags = params[:post][:tag_list].split(",").map(&:strip)
    else
      tags = []
    end
    
    if params[:save_as_draft].present?
      @post.status = 'unpublished'
    else
      @post.status = 'published'
    end
  
    if @post.update(post_params)
       @post.tags.destroy_all
       tag_objects = tags.map { |tag| { name: tag } }
       @post.tags.create(tag_objects)
      
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
        if current_user.admin?
          Notification.create(
            user: @post.user,
            admin: current_user.admin, # ログインしている管理者
            post: @post
          )
        end
      end
      if current_user.admin?  # 管理者がログインしているかどうかを確認する条件
        redirect_to request.referer
      else
        redirect_to draft_public_posts_path
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
  
  def post_params
    params.require(:post).permit(:user_id, :itinerary, :caption,:status, :main_image, :tag_list, :latitude, :longitude,
     map_attributes: [:id, :latitude, :longitude],
     images_attributes: [:id, :description, :image, :_destroy])
  end
  
end
