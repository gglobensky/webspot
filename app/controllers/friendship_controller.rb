class FriendshipController < ApplicationController

      # POST /projects or /projects.json
  def create
    @friendship = current_user.friendships.build(friendship_params)
    @friendship.user_id = current_user.id
    @friendship.friend_id = params[:friend_id]

    respond_to do |format|
      if @friendship.save
        format.json { render :show, status: :created, location: @friendship }
      else
        format.json { render json: @friendship.errors, status: :unprocessable_entity }
      end
      rescue ActiveRecord::RecordNotUnique
        format.json { render json: ["We've already got one"], status: :unprocessable_entity }
      
    end
  end

  def search
    searchFor = params[:searchFor]
    searchBy = params[:searchBy]
    searchTerms = params[:searchTerms]
    
    @friendships = current_user.friendships
    
    @usersFound = nil

    if searchFor == 'new_friends'
      if (searchTerms != "")
        @usersFound = User.where.not(id:@friendships.map(&:friend_id)).where.not("id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%')
      else
        @usersFound = User.where.not(id:@friendships.map(&:friend_id)).where.not("id = ?", current_user.id)
      end
    elsif searchFor == 'hidden_friends'

    elsif searchFor == 'current_friends'
      if (searchTerms != "")
        @usersFound = User.where(id:@friendships.map(&:friend_id)).where.not("id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%')
      else
        @usersFound = User.where(id:@friendships.map(&:friend_id)).where.not("id = ?", current_user.id)
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

    def friendship_params
      params.permit(:user_id, :friendship_id)
    end

end