class InterestTagging < ApplicationRecord
  belongs_to :interest_tag
  belongs_to :user
end
