class UsersController < ApplicationController
    include Rails.application.routes.url_helpers
    before_action :authenticate_user!

      def avatar
        render :json => { :status => "success", :url => avatar_urls}
      end

      def profile
        profile = current_user.profile
        msg = { :status => "success", :message => profile }
        render :json => msg # don't do msg.to_json
      end

      protected

      def avatar_urls
        if current_user
          rails_blob_path(current_user.avatar, disposition: "attachment", only_path: true) if current_user.avatar.attached?
        elsif
          ""
        end
      end
    

      def user_params
          params.require(:user).permit(:username, :email, :password, profile_attributes: [:id, :user_id, :bio, :date_of_birth])
      end
      

end
