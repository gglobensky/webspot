class TalentTagging < ApplicationRecord
  belongs_to :talent_tag
  belongs_to :user
end
