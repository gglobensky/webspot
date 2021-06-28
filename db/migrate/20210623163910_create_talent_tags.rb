class CreateTalentTags < ActiveRecord::Migration[6.1]
  def change
    create_table :talent_tags do |t|
      t.string :name

      t.timestamps
    end
  end
end
