class CreateHiddenPeople < ActiveRecord::Migration[6.1]
  def change
    create_table :hidden_people do |t|
      t.integer :user_id
      t.integer :hidden_person_id

      t.timestamps
    end
  end
end
