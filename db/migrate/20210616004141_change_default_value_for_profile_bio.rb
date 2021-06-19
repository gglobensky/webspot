class ChangeDefaultValueForProfileBio < ActiveRecord::Migration[6.1]
  def change
    change_column_default(:profiles, :bio, from: nil, to: "")
  end
end
