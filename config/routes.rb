Rails.application.routes.draw do

  get 'comments/create'
  get 'comments/destroy'
  resources :reports, only: [:create] do
  member do
      patch 'cancel_report', to: 'reports#cancel_report'
    end
  end
  
  devise_for :admin, skip: [:registrations, :passwords] , controllers: {
  sessions: "admin/sessions"
}

  namespace :admin do
      get 'top' => 'homes#top', as: 'top'
      resources :users, only: [:show, :index] do
        member do
          get 'posts'
          patch :activate
          patch :deactivate
        end
      end
      resources :reports, only: [:top] 
  end
  
  delete 'admin/reports/:id/delete_reported_post', to: 'reports#delete_reported_post', as: 'admin_delete_reported_post'
  patch 'reports/:id/cancel_comment_report', to: 'reports#cancel_comment_report', as: 'cancel_comment_report'
  
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
      # userページ
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
       resource :favorites, only: [:create, :destroy]
        resources :comments, only: [:create, :destroy]
        collection do
          get 'draft'
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

      
      get 'tags/:tag', to: 'posts#tagged', as: 'tag'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html


