class AddNotNullToUsername < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:users, :username, false)
  end
end
