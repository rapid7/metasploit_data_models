class RemovePnameValidation < ActiveRecord::Migration[4.2]

  def change
		change_column :web_vulns, :pname, :text, :null => true
  end

end
