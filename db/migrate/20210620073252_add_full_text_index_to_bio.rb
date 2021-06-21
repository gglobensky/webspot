class AddFullTextIndexToBio < ActiveRecord::Migration[6.1]
  def change
    add_index(:profiles, :bio, type: :fulltext)
  end
end
