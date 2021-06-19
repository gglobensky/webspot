class FollowingController < ApplicationController

      # POST /projects or /projects.json
  def create
    @following = current_user.followings.build(following_params)
    @following.user_id = current_user.id
    @following.friend_id = params[:friend_id]

    respond_to do |format|
      if @following.save
        format.json { render :show, status: :created, location: @following }
      else
        format.json { render json: @following.errors, status: :unprocessable_entity }
      end
      rescue ActiveRecord::RecordNotUnique
        format.json { render json: ["We've already got one"], status: :unprocessable_entity }
      
    end
  end

  def search
    searchFor = params[:searchFor]
    searchBy = params[:searchBy]
    searchTerms = params[:searchTerms]
    
    @followings = current_user.followings
    
    @usersFound = nil

    if searchFor == 'new_friends'
      if (searchTerms != "")
        @usersFound = User.where.not(id:@followings.map(&:friend_id)).where.not("id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%')
      else
        @usersFound = User.where.not(id:@followings.map(&:friend_id)).where.not("id = ?", current_user.id)
      end
    elsif searchFor == 'hidden_friends'

    elsif searchFor == 'current_friends'
      if (searchTerms != "")
        @usersFound = User.where(id:@followings.map(&:friend_id)).where.not("id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%')
      else
        @usersFound = User.where(id:@followings.map(&:friend_id)).where.not("id = ?", current_user.id)
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
      params.permit(:user_id, :friendship_id)
    end

end