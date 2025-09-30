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
      # 不正アクセス時はもと居た場所にリダイレクトまたはrootにリダイレクト
      flash[:alert] = I18n.t("devise.failure.unauthenticated")
      redirect_back(fallback_location: root_path)
    end
  end

  # POST /resource/sign_in
  def create
  # 入力された認証情報（メール/パスワード）を検証する
  self.resource = warden.authenticate!(auth_options)
  set_flash_message!(:notice, :signed_in)
  # セッションにユーザーを保存し、ログイン状態にする
  sign_in(resource_name, resource)
  # 呼び出し元でブロックが渡されていれば実行
  yield resource if block_given?
  # ログイン後のリダイレクト先を決めてレスポンスを返す
  respond_with resource, location: after_sign_in_path_for(resource)
end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected
  
  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new", login: params[resource_name][:login] }
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private
  # ログイン後のリダイレクト先を役割で分けました。
  def after_sign_in_path_for(resource)
    resource.admin? ? admin_homes_top_path : show_mypage_public_user_path(current_user)
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
