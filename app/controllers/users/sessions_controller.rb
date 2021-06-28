# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController

  before_action :process_token
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    user = User.find_by_email(sign_in_params[:email])
  
    if user && user.valid_password?(sign_in_params[:password])
      token = user.generate_jwt.to_json
      render json: { :status => "success", token: token, user: user, interest_tag_list: user.interest_tag_list, talent_tag_list: user.talent_tag_list }
    else
      password_error
    end
  end

  # def destroy
  #   byebug
  #   signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
  #   yield if block_given?
  #   render json: { result: signed_out.to_json }
  # end

  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def password_error
    content = resource.to_json
    msg = { :status => "error", :message => I18n.t('devise.failure.invalid', authentication_keys: 'email') }
    render :json => msg
  end  
  
  def password_valid
    content = resource.to_json
    msg = { :status => "200", :user => content }
    render :json => msg
  end

  def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request

    #check devise i18n
      render json: { result: 'signed out' }

  end

end
