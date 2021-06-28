class CreateTalentTaggings < ActiveRecord::Migration[6.1]
  def change
    create_table :talent_taggings do |t|
      t.references :talent_tag, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
