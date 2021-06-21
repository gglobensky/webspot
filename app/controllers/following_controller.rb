class FollowingController < ApplicationController
  include JwtProcessToken
  respond_to :json
  before_action :process_token


  def create
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

  def hide
    @hidden_person = current_user.hidden_people.build(hiding_params)

    @hidden_person.user_id = @current_user_id

    if @hidden_person.save
      render json: { status: "success" }
    else
      render json: { message: @hidden_person.errors, status: :unprocessable_entity }
    end
    rescue ActiveRecord::RecordNotUnique
      render json: { message: ["Already hidden"], status: :unprocessable_entity }
    end

  def search
    searchFor = params[:searchFor]
    searchBy = params[:searchBy]
    searchTerms = params[:searchTerms]
    
    @followings = current_user.followings
    @hidden_people = current_user.hidden_people.pluck(:hidden_person_id)
    @usersFound = nil
    @usersData = nil
#I feel that below could be DRYer

    if searchFor == 'new_people'
      if searchBy == 'bio'
        @usersFound = User.left_outer_joins(:avatar_attachment).joins(:profile).where.not(id: @hidden_people).where.not(id:@followings.map(&:followed_id)).where.not("users.id = ?", current_user.id).where('MATCH (bio) AGAINST (? IN BOOLEAN MODE)', searchTerms).pluck(:username, :bio, :blob_id, :id)
      else
        @usersFound = User.left_outer_joins(:avatar_attachment).joins(:profile).where.not(id: @hidden_people).where.not(id:@followings.map(&:followed_id)).where.not("users.id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%').pluck(:username, :bio, :blob_id, :id)
      end
    elsif searchFor == 'hidden_people'
      if searchBy == 'bio'
        @usersFound = User.left_outer_joins(:avatar_attachment).joins(:profile).where(id: @hidden_people).where.not(id:@followings.map(&:followed_id)).where.not("users.id = ?", current_user.id).where('MATCH (bio) AGAINST (? IN BOOLEAN MODE)', searchTerms).pluck(:username, :bio, :blob_id, :id)
      else
        @usersFound = User.left_outer_joins(:avatar_attachment).joins(:profile).where(id: @hidden_people).where.not(id:@followings.map(&:followed_id)).where.not("users.id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%').pluck(:username, :bio, :blob_id, :id)
      end   
    elsif searchFor == 'hidden_followed'
      if searchBy == 'bio'
        @usersFound = User.left_outer_joins(:avatar_attachment).joins(:profile).where(id: @hidden_people).where(id:@followings.map(&:followed_id)).where.not("users.id = ?", current_user.id).where('MATCH (bio) AGAINST (? IN BOOLEAN MODE)', searchTerms).pluck(:username, :bio, :blob_id, :id)
      else
        @usersFound = User.left_outer_joins(:avatar_attachment).joins(:profile).where(id: @hidden_people).where(id:@followings.map(&:followed_id)).where.not("users.id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%').pluck(:username, :bio, :blob_id, :id)
      end    
    elsif searchFor == 'followed'
      if searchBy == 'bio'
        @usersFound = User.left_outer_joins(:avatar_attachment).joins(:profile).where.not(id: @hidden_people).where(id:@followings.map(&:followed_id)).where.not("users.id = ?", current_user.id).where('MATCH (bio) AGAINST (? IN BOOLEAN MODE)', searchTerms).pluck(:username, :bio, :blob_id, :id)
      else
        @usersFound = User.left_outer_joins(:avatar_attachment).joins(:profile).where.not(id: @hidden_people).where(id:@followings.map(&:followed_id)).where.not("users.id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%').pluck(:username, :bio, :blob_id, :id)
      end   
    end

    response = @usersFound
    message = []

    $i = 0
    $num = response.count
    
    while $i < $num  do
      data = {username: @usersFound[$i][0], bio: @usersFound[$i][1], id: @usersFound[$i][3]}
      if (@usersFound[$i][2] != nil)
        data[:url] = rails_blob_path(ActiveStorage::Blob.find(@usersFound[$i][2]))
      else
        data[:url] = nil
      end
      message.push(data)
       $i +=1
    end

    render json: message.to_json
  end

  private

    def following_params
      params.permit(:followed_id)
    end

    def hiding_params
      params.permit(:hidden_person_id)
    end

end