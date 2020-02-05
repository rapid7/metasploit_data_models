class AddModuleFullNameToMatch < ActiveRecord::Migration[4.2]
  def change
    add_column :automatic_exploitation_matches, :module_fullname, :text
    add_index :automatic_exploitation_matches, :module_fullname
  end
end
