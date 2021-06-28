# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  prepend_before_action :authenticate_scope!, only: [:edit, :destroy]
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    sign_up_params["password_confirmation"] = sign_up_params["password"]
    user = User.new(sign_up_params)
    user.build_profile
    if user.save
    token = user.generate_jwt.to_json
      render json:  { :status => "success", token: token, user: user }
    else
      content = user.errors.messages.to_json
      msg = { :status => "error", :message => content }
      render :json => msg
    end
  rescue ActiveRecord::NotNullViolation
    content = resource.to_json
    msg = { :status => "error", :errors => {username: I18n.t('activerecord.errors.models.user.attributes.username.not_present')} }
    render :json => msg
  end


  #GET /resource/edit
  # def edit
  #   super
  # end

  #PUT /resource
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

      content = resource.to_json
      msg = {  :status => "success", :message => content }
      render :json => msg
    else
      clean_up_passwords resource
      set_minimum_password_length

      content = resource.errors.messages.to_json
      msg = { :status => "error", :message => content }
      render :json => msg

    end
  end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar, :username, profile_attributes: [:id, :user_id, :bio, :date_of_birth]])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource) devise not sending error
  # end
  def update_resource(resource, params)
      if (params[:password].blank?)
        params.delete(:current_password)
        resource.update_without_password(params)
      else
        resource.update_with_password(params)
      end
  end

  def json_error_response
    self.status = 200
    self.content_type = "application/json"
    msg = i18n_message.to_json
    self.response_body = { status: "error", message: i18n_message }.to_json
  end

end
