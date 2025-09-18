# frozen_string_literal: true

class CertificationCommons::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # deviceのログイン画面を役割で分けました。
  def new
    # フォームの作成
    self.resource = resource_class.new
    if request.fullpath.starts_with?('/admin')
      # admin 用のビューを使用
      render 'admin/sessions/new'
    elsif request.fullpath.starts_with?('/public')
      # public 用のビューを使用
      render 'public/sessions/new'
    else
      # 不正アクセス時は root にリダイレクト
      redirect_to root_path, alert: '不正なアクセスです。'
    end
  end


  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private
  # ログイン後のリダイレクト先を役割で分けました。
  def after_sign_in_path_for(resource)
    resource.admin? ? admin_top_path : show_mypage_public_user_path(current_user)
  end
  # ログアウト後のリダイレクト先を役割で分けました。
  def after_sign_out_path_for(resource_or_scope)
    if  previous_url = request.referer.start_with?('/admin')
      new_admin_session_path
    else
      root_path
    end
  end

end
