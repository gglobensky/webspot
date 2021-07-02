class CreateUserConversation < ActiveRecord::Migration[6.1]
  def change
    create_table :user_conversations, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :conversation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
