class CreateInterestTaggings < ActiveRecord::Migration[6.1]
  def change
    create_table :interest_taggings do |t|
      t.references :interest_tag, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
