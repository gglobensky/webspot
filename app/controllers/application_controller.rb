require 'jwt_process_token'
class ApplicationController < ActionController::API
include JwtProcessToken
respond_to :json
before_action :configure_permitted_parameters, if: :devise_controller?
before_action :process_token

  def authenticate_user!(options = {})
    head :unauthorized unless signed_in?
  end  

  def signed_in?
    @current_user_id.present?
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar, :username, profile_attributes: [:id, :user_id, :bio, :date_of_birth]])
  end

  def current_user
    @current_user ||= super || User.find(@current_user_id)
  end
  
end
