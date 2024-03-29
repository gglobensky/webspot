class Conversation < ApplicationRecord
    has_many :user_conversations
    has_many :users, through: :user_conversations 
    has_many :messages
    
    accepts_nested_attributes_for :messages, :allow_destroy => true
end
