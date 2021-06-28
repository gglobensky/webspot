class FollowingController < ApplicationController
  include JwtProcessToken
  respond_to :json
  before_action :process_token


  def follow
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

  def unfollow
    user = current_user
    if Following.where(following_params, user_id: user.id).destroy_all
      render json: { status: "success" }
    else
      render json: { status: "failure" }
    end
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

  def unhide
    user = current_user
    
    if HiddenPerson.where(hiding_params, user_id: user.id).destroy_all
      render json: { status: "success" }
    else
      render json: { status: "failure" }
    end

  end

  def search
    searchFor = params[:searchFor]
    searchTerms = ActiveRecord::Base.send(:sanitize_sql_like, params[:searchTerms])
    searchBy = params[:searchBy]

    user = current_user
    current_user_id = user.id

    userTalentIdList = "select distinct talent_taggings.talent_tag_id as id from talent_taggings right outer join users on talent_taggings.user_id = users.id where users.id = #{current_user_id}"
    userInterestIdList = "select distinct interest_taggings.interest_tag_id as id from interest_taggings right outer join users on interest_taggings.user_id = users.id where users.id = #{current_user_id}"
    tag_occurences = "count(case when talent_tag_id in (#{userTalentIdList}) then 1 end) + count(case when interest_tag_id in (#{userInterestIdList}) then 1 end) as occurences"
    
    interest_tags = "GROUP_CONCAT(DISTINCT interest_tags.name SEPARATOR ', ') AS interest_tags"
    talent_tags = "GROUP_CONCAT(DISTINCT talent_tags.name SEPARATOR ', ') AS talent_tags"

    selectedColumns = "username, bio, blob_id, users.id, #{interest_tags}, #{talent_tags}, #{tag_occurences}"

    profileJunction = "JOIN profiles ON users.id = profiles.user_id"
    activeStorageJunction = "LEFT OUTER JOIN active_storage_attachments asa ON users.id = asa.record_id"
    talentTagsAndTaggingsJunction = "LEFT OUTER JOIN (select user_id, talent_tags.id as talent_tag_id, name from talent_taggings JOIN talent_tags on talent_taggings.talent_tag_id = talent_tags.id) as talent_tags ON users.id = talent_tags.user_id"
    interestTagsAndTaggingsJunction = "LEFT OUTER JOIN (select user_id,interest_tags.id as interest_tag_id, name from interest_taggings JOIN interest_tags ON interest_taggings.interest_tag_id = interest_tags.id) as interest_tags ON users.id = interest_tags.user_id"

    @followings = user.followings.pluck("GROUP_CONCAT(followed_id)")[0]

    @hidden_people = user.hidden_people.pluck("GROUP_CONCAT(hidden_person_id)")[0]

    if searchBy == 'username' or searchTerms == ""
      search_where_condition = ActiveRecord::Base.send(:sanitize_sql_for_conditions, ["username LIKE ?", searchTerms + "%"])
    elsif searchBy == 'bio'
      search_where_condition = ActiveRecord::Base.send(:sanitize_sql_for_conditions, ["MATCH (bio) AGAINST (? IN BOOLEAN MODE)", searchTerms])
    else
      searchTermsArray = searchTerms.split(', ', -4)

      searchTerm = ""
      $i = 0
      $num = searchTermsArray.count

      while $i < $num do
        interest = ActiveRecord::Base.send(:sanitize_sql_for_conditions, ["?", "%" + searchTermsArray[$i] + "%"])
        searchTerm += interest
        if ($i != $num - 1)
          searchTerm += "OR "
        end

        $i +=1
      end

      if searchBy == 'interests'
        search_where_condition = "interest_tags LIKE #{searchTerm}"
      elsif searchBy == 'talents'
        search_where_condition = "talent_tags LIKE #{searchTerm}"
      end
      
    end

    followings_where_condition = @followings != nil ? " users.id IN (#{@followings}) " : " users.id IN ('')"
    hidden_people_where_condition = @hidden_people != nil ? " users.id IN (#{@hidden_people}) " : " users.id IN ('')"

    and_not_hidden_people = " AND NOT "
    and_hidden_people = " AND "

    and_not_followed_people = " AND NOT "
    and_followed_people = " AND "

#I feel that below could be DRYer

    if searchFor == 'new_people'
      query = "SELECT * FROM (SELECT #{selectedColumns} FROM users #{profileJunction} #{activeStorageJunction} #{talentTagsAndTaggingsJunction} #{interestTagsAndTaggingsJunction} WHERE NOT users.id = #{current_user_id} #{and_not_hidden_people} #{hidden_people_where_condition} #{and_not_followed_people} #{followings_where_condition} group by username ORDER BY occurences DESC) as t WHERE #{search_where_condition}"
    elsif searchFor == 'hidden_people'
      query = "SELECT * FROM (SELECT #{selectedColumns} FROM users #{profileJunction} #{activeStorageJunction} #{talentTagsAndTaggingsJunction} #{interestTagsAndTaggingsJunction} WHERE NOT users.id = #{current_user_id} #{and_hidden_people} #{hidden_people_where_condition} #{and_not_followed_people} #{followings_where_condition} group by username ORDER BY occurences DESC) as t WHERE #{search_where_condition}"
    elsif searchFor == 'hidden_followed'
      query = "SELECT * FROM (SELECT #{selectedColumns} FROM users #{profileJunction} #{activeStorageJunction} #{talentTagsAndTaggingsJunction} #{interestTagsAndTaggingsJunction} WHERE NOT users.id = #{current_user_id} #{and_hidden_people} #{hidden_people_where_condition} #{and_followed_people} #{followings_where_condition} group by username ORDER BY occurences DESC) as t WHERE #{search_where_condition}"
    elsif searchFor == 'followed'
      query = "SELECT * FROM (SELECT #{selectedColumns} FROM users #{profileJunction} #{activeStorageJunction} #{talentTagsAndTaggingsJunction} #{interestTagsAndTaggingsJunction} WHERE NOT users.id = #{current_user_id} #{and_not_hidden_people} #{hidden_people_where_condition} #{and_followed_people} #{followings_where_condition} group by username ORDER BY occurences DESC) as t WHERE #{search_where_condition}"
    else
      #searchFor is invalid, user tampered with form in suspicious way
    end


    results = ActiveRecord::Base.connection.execute(query).to_a

    message = []

    $i = 0
    $num = results.count

    while $i < $num do
      data = {username: results[$i][0], bio: results[$i][1], id: results[$i][3], interest_tag_list: results[$i][4], talent_tag_list: results[$i][5]}
      if (results[$i][2] != nil)
        data[:url] = rails_blob_path(ActiveStorage::Blob.find(results[$i][2]))
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