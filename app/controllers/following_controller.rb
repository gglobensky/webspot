class FollowingController < ApplicationController
  include JwtProcessToken
  respond_to :json
  before_action :process_token

      # POST /projects or /projects.json
  def create
    byebug
    @following = current_user.followings.build(following_params)

    @following.user_id = @current_user_id

    if @following.save
      json_data = @following.to_json
      render json: { status: "success", message: @following }
    else
      render json: { message: @following.errors, status: :unprocessable_entity }
    end
    rescue ActiveRecord::RecordNotUnique
      render json: { message: ["We've already got one"], status: :unprocessable_entity }
    end


  def search
    searchFor = params[:searchFor]
    searchBy = params[:searchBy]
    searchTerms = params[:searchTerms]
    
    @followings = current_user.followings
    
    @usersFound = nil

    if searchFor == 'new_people'
      if (searchTerms != "")
        @usersFound = User.where.not(id:@followings.map(&:followed_id)).where.not("id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%')
      else
        @usersFound = User.where.not(id:@followings.map(&:followed_id)).where.not("id = ?", current_user.id)
      end
    elsif searchFor == 'hidden_people'

    elsif searchFor == 'hidden_followed'

    elsif searchFor == 'followed'
      if (searchTerms != "")
        @usersFound = User.where(id:@followings.map(&:followed_id)).where.not("id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%')
      else
        @usersFound = User.where(id:@followings.map(&:followed_id)).where.not("id = ?", current_user.id)
      end
    end

    response = @usersFound.includes([:profile, :avatar_attachment])
    message = []
    response.each do |user|
      data = {user: user, profile: user.profile}
      data[:url] = (rails_blob_path(user.avatar, disposition: "attachment", only_path: true)) if user.avatar.attached?
      message.push(data)
    end
    render json: message.to_json
  end

  private

    def following_params
      params.permit(:followed_id)
    end

end