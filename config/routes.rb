Rails.application.routes.draw do
  # コメントの作成と削除
  get 'comments/create'
  delete 'comments/destroy'
  # 通報作成
  resources :reports, only: [:create] do
  member do
      patch 'cancel_report', to: 'reports#cancel_report'
    end
  end
  
  # 管理者側
  devise_for :admin, skip: [:registrations, :passwords] , controllers: {
  sessions: "admin/sessions"
}

  namespace :admin do
      get 'top' => 'homes#top', as: 'top'
      resources :users, only: [:show, :index] do
        member do
          get 'posts'
          # ユーザーステータス機能
          patch :activate
          patch :deactivate
        end
      end
      resources :reports, only: [:top] 
  end
   # 通報された投稿を削除するためのルート（管理者用）
  delete 'admin/reports/:id/delete_reported_post', to: 'reports#delete_reported_post', as: 'admin_delete_reported_post'
  # コメントの通報をキャンセルするためのルート
  patch 'reports/:id/cancel_comment_report', to: 'reports#cancel_comment_report', as: 'cancel_comment_report'
  
  # ユーザー側
  devise_for :users, controllers: {
  registrations: "public/registrations",
  sessions: 'public/sessions'
}

 # ゲストログイン用
  devise_scope :user do
    post 'guest_login', to: 'public/sessions#guest_login'
  end

  scope module: :public do
      root 'homes#top'
      get 'homes/about'
      resources :users, only: [:show, :index, :edit, :update] do
      # フォロー機能
       resource :relationships, only: [:create, :destroy]
      	get "followings" => "relationships#followings", as: "followings"
      	get "followers" => "relationships#followers", as: "followers"
        
        member do
            get 'mypage', to: 'users#show', as: 'show_mypage'
            get 'edit_information', to: 'users#edit', as: 'edit_information' 
            patch 'update_information', to: 'users#update', as: 'update_information' 
            delete 'unsubscribe', to: 'users#unsubscribe'
          end
        end
      # 投稿機能
      resources :posts, only: [:new, :create, :update, :destroy, :show, :index, :edit] do  
      # フォロー機能
       resource :favorites, only: [:create, :destroy]
      # コメント機能
        resources :comments, only: [:create, :destroy]
        collection do
          # 下書きルーティング
          get 'draft'
          # いいね機能
          get 'nice'
        end
         member do
          patch 'update_status'
        end
      end
      # 通知関連のルーティング
      resources :notifications, only: [] do
      member do
        patch :mark_as_read_and_destroy
        patch 'send_unpublish_notification'
      end
    end

      # タグのルーティング
      get 'tags/:tag', to: 'posts#tagged', as: 'tag'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html


