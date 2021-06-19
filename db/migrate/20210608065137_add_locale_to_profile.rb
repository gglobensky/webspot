class AddLocaleToProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :locale, :string
  end
end
