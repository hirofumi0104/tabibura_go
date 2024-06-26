class ApplicationController < ActionController::Base
  # before_action :authenticate_user!, except: [:top]
  
  before_action :configure_permitted_parameters, if: :devise_controller?
 
  def admin_signed_in?
    !current_admin.nil?
  end
  
  private
  
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email])
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
      devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password, :remember_me])
    end
end
