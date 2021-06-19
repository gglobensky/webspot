class CreateFollowings < ActiveRecord::Migration[6.1]
  def change
    create_table :followings do |t|
      t.integer :user_id
      t.integer :friend_id
      t.index [:id, :user_id]
      t.index [:user_id, :friend_id], unique: true
      t.timestamps
    end
  end
end
