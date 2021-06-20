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

    def hidden
      @hidden_people = current_user.hidden_people.pluck(:hidden_person_id)

      json_response = @hidden_people.to_json

      render json: { status: "success", message: json_response }
    end

  def search
    searchFor = params[:searchFor]
    searchBy = params[:searchBy]
    searchTerms = params[:searchTerms]
    
    @followings = current_user.followings
    @hidden_people = current_user.hidden_people.pluck(:hidden_person_id)
    @usersFound = nil

    if searchFor == 'new_people'
      @usersFound = User.where.not(id: @hidden_people).where.not(id:@followings.map(&:followed_id)).where.not("Users.id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%')
    elsif searchFor == 'hidden_people'
      @usersFound = User.where(id: @hidden_people).where.not(id:@followings.map(&:followed_id)).where.not("Users.id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%')
    elsif searchFor == 'hidden_followed'
      @usersFound = User.where(id: @hidden_people).where(id:@followings.map(&:followed_id)).where.not("Users.id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%')
    elsif searchFor == 'followed'
      @usersFound = User.where.not(id: @hidden_people).where(id:@followings.map(&:followed_id)).where.not("Users.id = ?", current_user.id).where(searchBy + ' LIKE ?', searchTerms + '%')
     
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

    def hiding_params
      params.permit(:hidden_person_id)
    end

end