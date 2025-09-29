class ApplicationController < ActionController::Base
  # before_action :authenticate_user!, except: [:top]
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  # headerの画像をheader.jsに渡す
  before_action :set_header_images

  private
  
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:login])
      devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :password, :remember_me])
    end

    # headerの画像をheader.jsに渡す
    def set_header_images
      @header_images ||= Dir.glob(Rails.root.join("app/assets/images/background/*.{jpg,png,jpeg}"))
                            .map { |path| ActionController::Base.helpers.asset_path("background/#{File.basename(path)}") }
    end
end
