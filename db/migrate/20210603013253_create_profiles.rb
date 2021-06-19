class CreateProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.text :bio
      t.date :date_of_birth

      t.timestamps
    end
  end
end
