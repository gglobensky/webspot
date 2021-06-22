class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_many :followings
  has_many :hidden_people
  has_one :profile
  has_many :interest_taggings
  has_many :interest_tags, through: :interest_taggings

  has_one_attached :avatar
  accepts_nested_attributes_for :profile, :allow_destroy => true
  
  def generate_jwt
    JWT.encode({id: id, exp: 60.days.from_now.to_i}, Rails.application.secrets.secret_key_base)
  end

  def interest_tag_list
    interest_tags.join(", ")
  end

  def interest_tag_list=(tags_string)
    tag_names = tags_string.split(",").collect{|s| s.strip.downcase}.uniq
    new_or_found_tags = tag_names.collect { |name| InterestTag.find_or_create_by(name: name) }
    self.interest_tags = new_or_found_tags
  end
  

end
