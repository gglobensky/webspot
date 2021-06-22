class InterestTag < ApplicationRecord
  has_many :interest_taggings
  has_many :users, through: :interest_taggings

  def to_s
    name
  end
end
