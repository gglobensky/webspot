class TalentTag < ApplicationRecord
    has_many :talent_taggings
    has_many :users, through: :talent_taggings
  
    def to_s
      name
    end
end
