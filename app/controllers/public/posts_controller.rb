class Public::PostsController < ApplicationController
  # ページネーション作成のモジュール
  include Pagination

  before_action :set_post, only: [:edit, :update, :show, :destroy,]
  before_action :authenticate_user!, except: [:index, :show, :tagged]

   # 新規投稿
  def new
    @post = Post.new
    @post.images.build
  end
  
  # 投稿とGoogleマップを取得
  def show
    @post = Post.includes(images: { image_attachment: :blob }).find(params[:id])
    @posts = Post.where(user: @post.user).order("RANDOM()").limit(5)
  end

  def index
    # 投稿の表示・検索条件(条件はPostモデル)
    @posts = Post.published 
             .with_attached_main_image
             .search(params[:q]) 
             .with_tag(params[:tag])
             .by_itinerary(params[:itinerary])           
             .includes(:tags, :user, :favorites)
             .page(params[:page]).per(10)

    # ユーザー表示・検索(条件はUserモデル)
    @users = User.excluding_admin
             .is_active
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
    @post = Post.includes(:map_pins, images: { image_attachment: :blob }).find(params[:id])
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
    
    # GoogleVisionApiを使ったタグ付けに使用していた。lib/vision.rb参照
    # if params[:tagging_option] == 'cloud_vision' && post_params[:main_image].present?
    #   tags = Vision.get_image_data(post_params[:main_image])
    # elsif params[:tagging_option] == 'manual' && params[:post][:tag_list].present?
    #   tags = params[:post][:tag_list].split(",").map(&:strip)
    # else
    #   tags = []
    # end
    
    if params[:tagging_option] == 'manual' && params[:post][:tag_list].present?
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
       @post.tags.create(tags.map { |tag| { name: tag } })
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
    
    # Cloud Visionは現状使わないのでコメントアウト
    # if params[:tagging_option] == 'cloud_vision' && post_params[:main_image].present?
    #   begin
    #     # Cloud Vision APIを使用してタグを取得
    #     tags = Vision.get_image_data(post_params[:main_image])
    #     Rails.logger.info "Cloud Vision tags: #{tags.inspect}"
    #   rescue => e
    #     Rails.logger.error "Cloud Vision API error: #{e.message}"
    #     tags = []
    #   end
    

    if params[:tagging_option] == 'manual' && params[:post][:tag_list].present?
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

      # マップのピン情報を再登録
      @post.map_pins.destroy_all
      if params[:post][:map_pins_attributes].present?
        params[:post][:map_pins_attributes].each do |_, pin_attr|
          @post.map_pins.create(
            latitude: pin_attr[:latitude],
            longitude: pin_attr[:longitude],
            label: pin_attr[:label]
          )
        end
      end
      
      if @post.unpublished?
        redirect_to draft_posts_path, notice: '投稿を下書きとして保存しました。'
      else
        redirect_to public_post_path(@post, referrer: public_user_path(@post.user)), notice: '投稿を更新しました。'
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
            sent_by_admin: true, # ログインしている管理者
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
    params.require(:post).permit(:user_id, :itinerary, :caption, :status, :main_image, :tag_list,
    map_pins_attributes: [:id, :latitude, :longitude, :label, :_destroy],
    images_attributes: [:id, :description, :image, :_destroy])
  end
  
end
