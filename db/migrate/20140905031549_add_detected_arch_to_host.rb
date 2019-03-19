class AddDetectedArchToHost < ActiveRecord::Migration[4.2]
  def change
    add_column :hosts, :detected_arch, :string, { :null => true }
  end
end
