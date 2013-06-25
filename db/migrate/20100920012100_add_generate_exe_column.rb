# Adds emails_templates.generate_exe.
class AddGenerateExeColumn < ActiveRecord::Migration
  # Removes email_templates.generate_exe.
  #
  # @return [void]
	def down
		remove_column :email_templates, :generate_exe
	end

  # Adds email_templates.generate_exe.
  #
  # @return [void]
	def up
		add_column :email_templates, :generate_exe, :boolean, :null => false, :default => false
  end
end
