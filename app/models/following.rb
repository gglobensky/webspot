class Following < ApplicationRecord
    belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
    belongs_to :followed, :class_name => 'User', :foreign_key => 'followed_id'
end
